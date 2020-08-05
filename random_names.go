package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strings"
	"sync"
)

func main() {
	var count int
	var filename string
	flag.IntVar(&count, "n", 0, "number of names")
	flag.StringVar(&filename, "f", "names.csv", "outfile")
	flag.Parse()
	if count == 0 {
		fmt.Printf("Wrong arguments\nUsage: -n <num of names> -f <outfile>\n")
		os.Exit(1)
	}
	count /= 5
	var wg sync.WaitGroup
	wg.Add(count)
	for i := 0; i < count; i++ {
		go func() {
			defer wg.Done()
			getNames(filename)
		}()
	}
	wg.Wait()
	fmt.Println("Names saved in", filename)
}
func getNames(filename string) {
	resp, err := http.Get("https://www.behindthename.com/random/random.php?number=2&sets=5&gender=both&surname=&randomsurname=yes&norare=yes&usage_eng=1%27")
	check(err)
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	str := string(body)
	r, _ := regexp.Compile("/name/.+?\">[A-Z][a-z]+")
	resArr := (r.FindAllString(str, -1))
	newRes := ""
	for i := 1; i < len(resArr)+1; i++ {
		if i%3 == 0 {
			newRes += strings.Split(resArr[i-1], ">")[1] + "\n"
			f, err1 := os.OpenFile(filename,
				os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
			check(err1)
			defer f.Close()
			_, err2 := f.WriteString(newRes)
			check(err2)
			newRes = ""
		} else {
			newRes += strings.Split(resArr[i-1], ">")[1] + ","
		}
	}
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}
