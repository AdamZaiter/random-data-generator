#lang racket

(require html-parsing 
         net/url
         sxml
         xml)

(define MAX-THREADS 100)
(define URL "https://www.behindthename.com/random/random.php?number\
  =2&sets=5&gender=both&surname=&randomsurname=yes&norare=yes&usage_eng=1%27")
(define work-channel (make-channel))
(define result-channel (make-channel))

(define (make-request url)
  (http-sendrecv/url
    (string->url url)
    #:method #"GET"))

(define (parse-args)
  (define number (make-parameter #f))
  (define file (make-parameter #f))
  (command-line
    #:program "Random names"
    #:once-each
    (("-n" "--number") num "Number of names to produce"
                       (number num))
    (("-f" "--file") f "Save file" 
                     (file f))
    #:usage-help "racket random_data_gen.rkt -n <number> -f <filename>")
  (values (quotient (string->number (number)) 5) (file)))
  

(define (comma-format names)
  (format "~a,~a,~a,~a,~a@test-domain.com" 
          (car names) (cadr names) (caddr names)
          (random 100000000 999999999) (car names)))

(define (json-format names)
  (format "{\"First name\": \"~a\", \
\"Middle name\": \"~a\", \
\"Last name\": \"~a\", \
\"Phone number\": \"~a\", \
\"Email\": \"~a@test-domain.com\"}," 
          (car names) (cadr names) (caddr names)
          (random 100000000 999999999) (car names)))

;---------------XML version---------------;
(define (get-5-names)
  (define-values (status headers in-port) 
    (make-request URL))
  (define xml-lst (html->xexp in-port))
  (define ret-lst '())
  (define lst ((sxpath "//a[@class='plain']") xml-lst))
  (format-lst
    (return-names lst)))

(define (return-names lst [new-lst '()])
  (if (empty? lst)
    '()
    (cons (caddr (car lst)) (return-names (cdr lst)))))

(define (format-lst lst [ctr 1])
  (if (empty? lst) 
    '()
    (let-values ([(left right) (split-at lst 3)])
      (append (list left) (format-lst right (add1 ctr))))))
;-----------------------------------------;

;--------------Regex version--------------;
(define (get-5-names-regex)
  (define-values (status headers in) (make-request URL))
  (let* ([html (port->string in)]
         [lst (regexp-match* #px"/name/.+?\">\\w+" html)])
    (output-to-file (get-names-regex lst))))

(define (get-names-regex lst)
  (if (empty? lst) '()
    (let* ([str (car lst)]
           [name (cadr (string-split str ">"))])
      (cons name (get-names-regex (cdr lst))))))

;-----------------------------------------;

(define (output-to-file names format-style file-name)
  (unless (empty? names)
    (let ([res (format-style (car names))])
      (call-with-output-file file-name
                             #:exists 'append
                             (lambda (out)
                               (displayln res out)))
      (output-to-file (cdr names) format-style file-name))))

(define (make-work-thread id format-style file-name)
  (thread 
    (let loop()
      (lambda ()
        (channel-get work-channel)
        (output-to-file (get-5-names) format-style file-name)
        (channel-put result-channel 1)))))

(define (exit-after-completion num iterations)
  (unless (= num iterations)
    (exit-after-completion (+ (channel-get result-channel) num) iterations)))

(define (make-workers iterations format-style file-name)
  (for ([i (min iterations MAX-THREADS)])
    (make-work-thread i format-style file-name))
  (void))

(define (main)
  (define-values (iterations file-name) (parse-args))
  (define file-extension 
    (let ([extension (car (regexp-match #px"\\.\\w+" file-name))])
      (if (or (equal? ".json" extension)
              (equal? ".csv" extension)
              (equal? ".txt" extension))
        extension
        (begin (printf "Output file has to be one of .json, .csv, .txt")
                 (exit)))))
        (define format-style (if (equal? ".json" file-extension)
                               json-format
                               comma-format))
        (make-workers iterations format-style file-name)
        (for ([i iterations])
          (channel-put work-channel 1))
        (call-with-output-file file-name
                               #:exists 'append
                               (lambda (out)
                                 (display "[" out)))
        (exit-after-completion 0 iterations)
        (call-with-output-file file-name
                               #:exists 'append
                               (lambda (out)
                                 (display "]," out))))

(main)
