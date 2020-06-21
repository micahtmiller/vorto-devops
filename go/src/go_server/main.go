package main

import (
	"fmt"
	"log"
	"net/http"
)

func home_get_result() string {
	return "You've got a response!"
}

func home_handler(w http.ResponseWriter, r *http.Request) {
	some_logic := home_get_result()
	fmt.Fprintf(w, some_logic)
}

func main() {
	http.HandleFunc("/", home_handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}