package db2

import (
	"context"
	"database/sql"
	"database/sql/driver"
)

func init() {
	sql.Register("db2", &Driver{})
}

// Driver implements database/sql/driver.Driver and driver.DriverContext interfaces.
type Driver struct{}

// Open returns a new connection to the database. The name is a DSN or connection URL.
func (d *Driver) Open(name string) (driver.Conn, error) {
	connector, err := d.OpenConnector(name)
	if err != nil {
		return nil, err
	}
	return connector.Connect(context.Background())
}

// OpenConnector parses the name and returns a Connector for database/sql pool management.
func (d *Driver) OpenConnector(name string) (driver.Connector, error) {
	cfg, err := ParseDSN(name)
	if err != nil {
		return nil, err
	}
	return NewConnector(cfg), nil
}

var (
	_ driver.Driver        = (*Driver)(nil)
	_ driver.DriverContext = (*Driver)(nil)
)
