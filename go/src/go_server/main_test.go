package main

import (
	"testing"
)

func TestHello( t *testing.T ) {
	result := "You've got a response!"
	
	if result != "You've got a response!" {
		t.Errorf("Failed test %s", result)
	}
}