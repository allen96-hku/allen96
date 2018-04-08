package main

import (
	"fmt"
	"math/rand"
	"regexp"
	"time"
)

const charset = "abcdefghijklmnopqrstuvwxyz" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))

func main() {
	for i := 1; i < 65; i++ {
		s := String(i)
		if regexp.MustCompile(`^[0-9]+$`).MatchString(string(s[0])) == true {
			i--
			continue
		}
		fmt.Println(s)
	}
}

func StringWithCharset(length int, charset string) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

func String(length int) string {
	return StringWithCharset(length, charset)
}
