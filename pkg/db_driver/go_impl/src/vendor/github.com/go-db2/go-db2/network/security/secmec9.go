package security

import (
	"bytes"
	"crypto/cipher"
	"crypto/des"
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
)

// Diffie-Hellman parameters for DRDA SECMEC 9 (DES Encrypted Password)
// https://wiki.apache.org/db-derby/SecurityMechanism
var (
	// Prime p (256 bits)
	DHSecmec9Prime, _ = new(big.Int).SetString("C62112D73EE613F0947AB31F0F6846A1BFF5B3A4CA0D60BC1E4C7A0D8C16B3E3", 16)
	// Base generator g
	DHSecmec9Base, _ = new(big.Int).SetString("4690FA1F7B9E1D4442C86C9114603FDECF071EDCEC5F626E21E256AED9EA34E4", 16)
)

// GenerateDHPrivateKey generates a random client private key in range [2, p-1].
func GenerateDHPrivateKey() (*big.Int, error) {
	max := new(big.Int).Sub(DHSecmec9Prime, big.NewInt(2))
	priv, err := rand.Int(rand.Reader, max)
	if err != nil {
		return nil, fmt.Errorf("failed to generate DH private key: %w", err)
	}
	priv.Add(priv, big.NewInt(2))
	return priv, nil
}

// CalculateDHPublicKey computes the client's public key: g^priv mod p.
func CalculateDHPublicKey(priv *big.Int) []byte {
	pub := new(big.Int).Exp(DHSecmec9Base, priv, DHSecmec9Prime)
	b := pub.Bytes()
	if len(b) < 32 {
		padded := make([]byte, 32)
		copy(padded[32-len(b):], b)
		return padded
	}
	if len(b) > 32 {
		return b[len(b)-32:]
	}
	return b
}

// CalculateSessionKey computes the shared session key: serverPublic^priv mod p.
func CalculateSessionKey(serverSecTkn []byte, clientPriv *big.Int) ([]byte, error) {
	if len(serverSecTkn) == 0 {
		return nil, errors.New("server security token is empty")
	}
	serverPub := new(big.Int).SetBytes(serverSecTkn)

	// Security validation: Prevent small-subgroup attacks (SEC-08)
	if serverPub.Cmp(big.NewInt(1)) <= 0 {
		return nil, errors.New("db2: invalid DH server public key: value must be greater than 1")
	}
	pMinusOne := new(big.Int).Sub(DHSecmec9Prime, big.NewInt(1))
	if serverPub.Cmp(pMinusOne) >= 0 {
		return nil, errors.New("db2: invalid DH server public key: value must be less than p-1")
	}

	shared := new(big.Int).Exp(serverPub, clientPriv, DHSecmec9Prime)
	b := shared.Bytes()
	if len(b) < 32 {
		padded := make([]byte, 32)
		copy(padded[32-len(b):], b)
		return padded, nil
	}
	if len(b) > 32 {
		return b[len(b)-32:], nil
	}
	return b, nil
}

// EncryptPasswordSECMEC9 encrypts a password using DES-CBC with PKCS#5 padding and the derived session key.
func EncryptPasswordSECMEC9(password string, serverSecTkn []byte, clientPriv *big.Int) ([]byte, error) {
	if len(serverSecTkn) < 20 {
		return nil, fmt.Errorf("server security token too short: expected at least 20 bytes, got %d", len(serverSecTkn))
	}

	sessionKey, err := CalculateSessionKey(serverSecTkn, clientPriv)
	if err != nil {
		return nil, err
	}

	// In DRDA SECMEC 9:
	// IV is bytes 12..20 of server security token
	// Key is bytes 12..20 of the 32-byte session key
	iv := serverSecTkn[12:20]
	key := sessionKey[12:20]

	block, err := des.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("failed to create DES cipher: %w", err)
	}

	plain := pkcs5Pad([]byte(password), des.BlockSize)
	encrypted := make([]byte, len(plain))

	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(encrypted, plain)

	return encrypted, nil
}

// pkcs5Pad adds PKCS#5 / PKCS#7 padding to data.
func pkcs5Pad(data []byte, blockSize int) []byte {
	padding := blockSize - (len(data) % blockSize)
	padText := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(data, padText...)
}
