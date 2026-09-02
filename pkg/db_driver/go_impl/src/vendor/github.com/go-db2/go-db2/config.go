package db2

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/go-db2/go-db2/network"
)

// Config holds the configuration options parsed from a connection string (DSN or URL).
type Config struct {
	Host              string
	Port              int
	Database          string
	User              string
	Password          string
	UseSSL            bool
	SSLRootCAPath     string
	SSLClientCertPath string
	SSLClientKeyPath  string
	Timeout           time.Duration
	BlockSize         int
	SecurityMechanism uint16
	KerberosSPN       string
	KerberosRealm     string
	Krb5ConfigFile    string
	Krb5KeytabFile    string
	Krb5CCacheFile    string
	ClientApplName    string
	ClientWrkstnName  string
	ClientUserid      string
	ClientAcctng      string
	ClientCorrToken   string
	Params            map[string]string
}

// String implements fmt.Stringer to ensure sensitive credentials (Password) are redacted in logs.
func (c Config) String() string {
	return fmt.Sprintf("Config{Host:%s, Port:%d, Database:%s, User:%s, Password:\"******\", UseSSL:%t, Timeout:%v}",
		c.Host, c.Port, c.Database, c.User, c.UseSSL, c.Timeout)
}

// GoString implements fmt.GoStringer to ensure sensitive credentials (Password) are redacted in logs.
func (c Config) GoString() string {
	return c.String()
}

// NewConfig returns a default Config with standard Db2 settings.
func NewConfig() *Config {
	return &Config{
		Host:      "localhost",
		Port:      50000,
		Timeout:   30 * time.Second,
		BlockSize: 65535,
		Params:    make(map[string]string),
	}
}

// ParseDSN parses a Db2 connection string in either URL format or Key-Value DSN format.
//
// Examples:
//
//	db2://user:password@localhost:50000/sample?ssl=true&timeout=30s
//	host=localhost;port=50000;database=sample;user=db2inst1;password=password;ssl=false;
func ParseDSN(dsn string) (*Config, error) {
	dsn = strings.TrimSpace(dsn)
	if dsn == "" {
		return nil, ErrInvalidConnectionStr
	}

	if strings.HasPrefix(dsn, "db2://") || strings.HasPrefix(dsn, "db2s://") {
		return parseURL(dsn)
	}

	return parseKeyValue(dsn)
}

func parseURL(dsn string) (*Config, error) {
	u, err := url.Parse(dsn)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrInvalidConnectionStr, err)
	}

	if u.Scheme != "db2" && u.Scheme != "db2s" {
		return nil, fmt.Errorf("%w: expected scheme 'db2' or 'db2s'", ErrInvalidConnectionStr)
	}

	cfg := NewConfig()
	if u.Scheme == "db2s" {
		cfg.UseSSL = true
	}

	// Host and Port
	if u.Hostname() != "" {
		cfg.Host = u.Hostname()
	}
	if u.Port() != "" {
		port, err := strconv.Atoi(u.Port())
		if err != nil || port <= 0 || port > 65535 {
			return nil, fmt.Errorf("%w: invalid port %s", ErrInvalidConnectionStr, u.Port())
		}
		cfg.Port = port
	}

	// Database name (Path)
	dbName := strings.TrimPrefix(u.Path, "/")
	if dbName == "" {
		return nil, fmt.Errorf("%w: missing database name", ErrInvalidConnectionStr)
	}
	cfg.Database = dbName

	// User and Password
	if u.User != nil {
		cfg.User = u.User.Username()
		if pwd, set := u.User.Password(); set {
			cfg.Password = pwd
		}
	}

	// Query parameters
	query := u.Query()
	for key, values := range query {
		if len(values) > 0 {
			applyParam(cfg, key, values[0])
		}
	}

	return cfg, nil
}

func parseKeyValue(dsn string) (*Config, error) {
	cfg := NewConfig()
	pairs := strings.Split(dsn, ";")

	for _, pair := range pairs {
		pair = strings.TrimSpace(pair)
		if pair == "" {
			continue
		}

		parts := strings.SplitN(pair, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])
		applyParam(cfg, key, val)
	}

	return cfg, nil
}

func applyParam(cfg *Config, key, val string) {
	lowerKey := strings.ToLower(key)
	switch lowerKey {
	case "host", "server", "hostname":
		cfg.Host = val
	case "port":
		if port, err := strconv.Atoi(val); err == nil && port > 0 && port <= 65535 {
			cfg.Port = port
		}
	case "database", "dbname", "db":
		cfg.Database = val
	case "user", "uid", "username":
		cfg.User = val
	case "password", "pwd":
		cfg.Password = val
	case "ssl", "use_ssl", "usessl":
		cfg.UseSSL = (strings.ToLower(val) == "true" || val == "1" || strings.ToLower(val) == "yes")
		if cfg.UseSSL && cfg.Port == 50000 {
			cfg.Port = 50001
		}
	case "ssl_root_ca", "ssl_ca", "sslrootcapath", "ssl_ca_path":
		cfg.SSLRootCAPath = val
		cfg.UseSSL = true
	case "ssl_client_cert_path", "ssl_client_cert", "sslcert", "cert":
		cfg.SSLClientCertPath = val
		cfg.UseSSL = true
	case "ssl_client_key_path", "ssl_client_key", "sslkey", "key":
		cfg.SSLClientKeyPath = val
		cfg.UseSSL = true
	case "timeout", "connect_timeout":
		if d, err := time.ParseDuration(val); err == nil {
			cfg.Timeout = d
		} else if sec, err := strconv.Atoi(val); err == nil {
			cfg.Timeout = time.Duration(sec) * time.Second
		}
	case "block_size", "blocksize", "qryblksz":
		if sz, err := strconv.Atoi(val); err == nil && sz >= 1024 && sz <= 1048576 {
			cfg.BlockSize = sz
		}
	case "security_mechanism", "secmec", "auth_mechanism", "auth":
		lowerVal := strings.ToLower(val)
		switch lowerVal {
		case "kerberos", "gssapi", "7":
			cfg.SecurityMechanism = 7
		case "encrypted_kerberos", "11":
			cfg.SecurityMechanism = 11
		case "dh_encrypted_password", "secmec9", "9":
			cfg.SecurityMechanism = 9
		case "encrypted_password", "secmec6", "6":
			cfg.SecurityMechanism = 6
		case "plaintext", "secmec3", "3":
			cfg.SecurityMechanism = 3
		case "user_only", "secmec4", "4":
			cfg.SecurityMechanism = 4
		default:
			if code, err := strconv.Atoi(val); err == nil && code > 0 {
				cfg.SecurityMechanism = uint16(code)
			}
		}
	case "spn", "service_principal", "server_principal":
		cfg.KerberosSPN = val
	case "realm", "krb5_realm":
		cfg.KerberosRealm = val
	case "krb5_config", "krb5_conf":
		cfg.Krb5ConfigFile = val
	case "krb5_keytab", "keytab":
		cfg.Krb5KeytabFile = val
	case "krb5_ccache", "ccache":
		cfg.Krb5CCacheFile = val
	case "client_applname", "applname", "application_name", "appname":
		cfg.ClientApplName = val
	case "client_wrkstnname", "wrkstnname", "workstation_name", "workstation":
		cfg.ClientWrkstnName = val
	case "client_userid", "client_user", "end_user":
		cfg.ClientUserid = val
	case "client_acctng", "acctng", "accounting":
		cfg.ClientAcctng = val
	case "client_corr_token", "corr_token", "correlation_token":
		cfg.ClientCorrToken = val
	default:
		cfg.Params[key] = val
	}
}

// ToSessionConfig converts Config to the network.SessionConfig structure.
func (c *Config) ToSessionConfig() network.SessionConfig {
	return network.SessionConfig{
		Host:              c.Host,
		Port:              c.Port,
		Database:          c.Database,
		User:              c.User,
		Password:          c.Password,
		UseSSL:            c.UseSSL,
		SSLRootCAPath:     c.SSLRootCAPath,
		SSLClientCertPath: c.SSLClientCertPath,
		SSLClientKeyPath:  c.SSLClientKeyPath,
		Timeout:           c.Timeout,
		BlockSize:         c.BlockSize,
		SecurityMechanism: c.SecurityMechanism,
		KerberosSPN:       c.KerberosSPN,
		KerberosRealm:     c.KerberosRealm,
		Krb5ConfigFile:    c.Krb5ConfigFile,
		Krb5KeytabFile:    c.Krb5KeytabFile,
		Krb5CCacheFile:    c.Krb5CCacheFile,
		ClientApplName:    c.ClientApplName,
		ClientWrkstnName:  c.ClientWrkstnName,
		ClientUserid:      c.ClientUserid,
		ClientAcctng:      c.ClientAcctng,
		ClientCorrToken:   c.ClientCorrToken,
	}
}
