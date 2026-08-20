package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"flag"
	"fmt"
	"io"
	"os"

	"golang.org/x/crypto/argon2"
)

func DerireKey(password []byte, salt []byte) []byte {
	var time uint32 = 1
	var memory uint32 = 64 * 1024
	var threads uint8 = 4
	var keyLength uint32 = 32

	return argon2.IDKey(password, salt, time, memory, threads, keyLength)
}

func encryptFile(password []byte, file string) error {

	salt := make([]byte, 16)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
		return err
	}

	key := DerireKey(password, salt)

	plain, err := os.ReadFile(file)
	if err != nil {
		return err
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return err
	}

	ciphertext := gcm.Seal(nil, nonce, plain, nil)

	var fileData []byte
	fileData = append(fileData, salt...)
	fileData = append(fileData, nonce...)
	fileData = append(fileData, ciphertext...)

	return os.WriteFile(file, fileData, 0600)
}

func decryptFile(password []byte, file string) error {
	fileData, err := os.ReadFile(file)
	if err != nil {
		return err
	}

	if len(fileData) < 16 {
		return fmt.Errorf("file data too short")
	}
	salt := fileData[:16]

	key := DerireKey(password, salt)

	block, err := aes.NewCipher(key)
	if err != nil {
		return err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return err
	}

	nonceStart := 16
	nonceEnd := nonceStart + gcm.NonceSize()
	if len(fileData) < nonceEnd {
		return fmt.Errorf("nonce not found in file data")
	}
	nonce := fileData[nonceStart:nonceEnd]
	ciphertext := fileData[nonceEnd:]

	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return fmt.Errorf("FAILED: Wrong password? or corrupted file? " + err.Error())
	}

	return os.WriteFile(file, plaintext, 0600)
}

func main() {
	encryptFileFlag := flag.String("encrypt", "", "encrypt file, path to the file")
	DecryptFileFlag := flag.String("decrypt", "", "decrypt file, path to the file")
	flag.Parse()

	if *encryptFileFlag != "" {
		encryptFile([]byte("input please"), *encryptFileFlag)
	} else if *DecryptFileFlag != "" {
		decryptFile([]byte("input please"), *DecryptFileFlag)
	}
}
