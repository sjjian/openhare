package security

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"net"
	"os"
)

// TLSConfig holds connection security parameters for TLS/SSL.
type TLSConfig struct {
	EnableTLS          bool
	InsecureSkipVerify bool
	ServerName         string
	CACertPath         string
	ClientCertPath     string
	ClientKeyPath      string
}

// WrapTLS upgrades an existing net.Conn to a secure TLS connection.
func WrapTLS(conn net.Conn, cfg TLSConfig) (net.Conn, error) {
	if !cfg.EnableTLS {
		return conn, nil
	}

	tlsConf := &tls.Config{
		ServerName:         cfg.ServerName,
		InsecureSkipVerify: cfg.InsecureSkipVerify,
		MinVersion:         tls.VersionTLS12,
	}

	if cfg.CACertPath != "" {
		caData, err := os.ReadFile(cfg.CACertPath)
		if err != nil {
			return nil, fmt.Errorf("failed to read TLS CA certificate at %s: %w", cfg.CACertPath, err)
		}
		pool := x509.NewCertPool()
		if !pool.AppendCertsFromPEM(caData) {
			return nil, fmt.Errorf("failed to parse TLS CA certificate from %s", cfg.CACertPath)
		}
		tlsConf.RootCAs = pool
	}

	if cfg.ClientCertPath != "" && cfg.ClientKeyPath != "" {
		cert, err := tls.LoadX509KeyPair(cfg.ClientCertPath, cfg.ClientKeyPath)
		if err != nil {
			return nil, fmt.Errorf("failed to load TLS client certificate/key pair: %w", err)
		}
		tlsConf.Certificates = []tls.Certificate{cert}
	}

	tlsConn := tls.Client(conn, tlsConf)
	if err := tlsConn.Handshake(); err != nil {
		return nil, fmt.Errorf("TLS handshake failed: %w", err)
	}

	return tlsConn, nil
}
