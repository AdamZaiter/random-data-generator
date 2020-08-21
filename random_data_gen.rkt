#lang racket

(require html-parsing 
         net/url
         sxml
         xml)

(define MAX-THREADS 100)
(define URL "https://www.behindthename.com/random/random.php?number\
=2&sets=5&gender=both&surname=&randomsurname=yes&norare=yes&usage_eng=1%27")

(define (make-request url)
  (http-sendrecv/url
    (string->url url)
    #:method #"GET"))

#| 1st command line argument is the number of names needed |#
#| 2nd is the file name with the extension json, csv or txt |#
(define (parse-args)
  (define x (current-command-line-arguments))
  (if (and (number? (string->number (vector-ref x 0)))
           (= (vector-length x) 2))
    (let ([ctr (string->number (vector-ref x 0))]
          [str (vector-ref x 1)])
      (values (if (> ctr 5) (quotient ctr 5) 1)
              str))
    (begin (printf "Usage: \nFirst argument -> Number of names needed
    Second Argument -> file name(.json, .csv or .txt)\n")
    (exit))))

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

(define work-channel (make-channel))
(define result-channel (make-channel))

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
        (begin (printf "Usage: \nFirst argument -> Number of names needed
                       Second Argument -> file name(.json, .csv or .txt)\n")
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
