package db2

import (
	"context"
	"database/sql/driver"

	"github.com/go-db2/go-db2/network"
)

// Connector implements the database/sql/driver.Connector interface.
type Connector struct {
	cfg    *Config
	driver driver.Driver
}

// NewConnector creates a new Connector from a parsed Config.
func NewConnector(cfg *Config) *Connector {
	return &Connector{
		cfg:    cfg,
		driver: &Driver{},
	}
}

// Connect returns a new active connection to the database.
func (c *Connector) Connect(ctx context.Context) (driver.Conn, error) {
	sessionCfg := c.cfg.ToSessionConfig()
	session := network.NewSession(sessionCfg)

	if err := session.Connect(ctx); err != nil {
		return nil, err
	}

	return NewConn(session, c.cfg), nil
}

// Driver returns the underlying Driver of the Connector.
func (c *Connector) Driver() driver.Driver {
	return c.driver
}

var _ driver.Connector = (*Connector)(nil)
