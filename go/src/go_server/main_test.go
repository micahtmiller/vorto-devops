package main

import (
	"testing"
)

func TestHello( t *testing.T ) {
	result := home_get_result()

	if result != "You've got a response!" {
		t.Errorf("Failed test %s", result)
	}
}