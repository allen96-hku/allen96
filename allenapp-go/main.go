package main

import (
	"fmt"
	"os"

	"github.com/allen96/allenapp/blockchain"
	"github.com/allen96/allenapp/web"
	"github.com/allen96/allenapp/web/controllers"
)

func main() {
	// Definition of the Fabric SDK properties
	fSetup := blockchain.FabricSetup{
		// Channel parameters
		ChannelID:     "hkuchannel",
		ChannelConfig: os.Getenv("GOPATH") + "/src/github.com/allen96/allenapp/fixtures/channel-artifacts/hkuchannel.tx",

		// Chaincode parameters
		ChainCodeID:     "hkucc",
		ChaincodeGoPath: os.Getenv("GOPATH"),
		ChaincodePath:   "github.com/allen96/allenapp/chaincode/hkuchaincode/go",
		OrgAdmin:        "Admin",
		OrgName:         "HallA",
		ConfigFile:      "config.yaml",

		// User parameters
		UserName: "User1",
	}

	// Initialization of the Fabric SDK from the previously set properties
	err := fSetup.Initialize()
	if err != nil {
		fmt.Printf("Unable to initialize the Fabric SDK: %v\n", err)
	}

	// Install and instantiate the chaincode
	err = fSetup.InstallAndInstantiateCC()
	if err != nil {
		fmt.Printf("Unable to install and instantiate the chaincode: %v\n", err)
	}

	// Launch the web application listening
	app := &controllers.Application{
		Fabric: &fSetup,
	}
	web.Serve(app)
}
