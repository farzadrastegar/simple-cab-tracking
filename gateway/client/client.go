package client

import (
	"github.com/spf13/viper"
	"net/http"
	"github.com/farzadrastegar/simple-cab/gateway"
)

type RequestService interface {
	ExecuteRequest(req *http.Request) (*http.Response, error)
}

// Client represents a client to connect to the HTTP server.
type Client struct {
	cabService CabService

	Handler *Handler
}

// NewClient returns a new instance of Client.
func NewClient() *Client {
	// Read CheckZombieStatus service's address and port.
	localServerAddr = viper.GetString("servers.internal.address")
	localServerPort = viper.GetString("servers.internal.port")

	c := &Client{
		Handler: NewHandler(),
	}

	//c.cabService.client = c
	c.cabService.handler = &c.Handler
	return c
}

// Connect returns the cabservice from client.
func (c *Client) Connect() gateway.CabService {
	return &c.cabService
}
