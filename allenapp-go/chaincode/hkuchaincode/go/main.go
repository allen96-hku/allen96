//Licensed to Allen Ngan

// ==== CHAINCODE EXECUTION SAMPLES (CLI) ==================
// ==== Query ====
/*

 */

// ==== Rich Query ====
/*

 */

// ==== Invoke ====
/*

 */

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"hash/fnv"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

type account struct {
	ObjectType string  `json:"docType"` //docType is used to distinguish the various types of objects in state database
	ACNumber   string  `json:"ACNumber"`
	Owner      string  `json:"Owner"`
	Balance    float64 `json:"Balance"`
	Nonce      int     `json:"Nonce"`
}

// {"ACNumber":"e989eab5b6e70e78","Balance":20,"Nonce":0,"Owner":"Admin@athclub.hku.com","docType":"ac"}

type user struct {
	ObjectType string  `json:"docType"` //docType is used to distinguish the various types of objects in state database
	Name       string  `json:"Name"`
	ACi        int     `json:"ACi"`    // Account Index
	ACnDel     int     `json:"ACnDel"` // Number of account deleted
	Equity     float64 `json:"Equity"`
}

// {"ACi":0,"ACnDel":0,"Equity":0,"Name":"Admin@hallA.hku.com","docType":"user"}

// Main
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}

// Init - initializes chaincode
// ===========================
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	objectType := "ac"
	acNumber := "SystemAC"
	owner := "System"
	balance := 100000.00
	nonce := 0
	ac := &account{objectType, acNumber, owner, balance, nonce}
	acJSONasBytes, err := json.Marshal(ac)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(acNumber, acJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- system ac created")
	return shim.Success(nil)
}

// Invoke - Our entry point for Invocations
// ========================================
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + function)

	// Handle different functions
	if function == "initUser" { //create a new user
		return t.initUser(stub, args)
	} else if function == "initAC" { //create a new account
		return t.initAC(stub, args)
	} else if function == "readState" {
		return t.readState(stub, args)
	} else if function == "delAC" {
		return t.delAC(stub, args)
	} else if function == "delUser" {
		return t.delUser(stub, args)
	} else if function == "pay" {
		return t.pay(stub, args)
	} else if function == "addValue" {
		return t.addValue(stub, args)
	} else if function == "getHistory" {
		return t.getHistory(stub, args)
	}

	fmt.Println("invoke did not find func: " + function) //error
	return shim.Error("Received unknown function invocation")
}

//////////////////////////////////////////////////////////////////////
///////////////////////// Development Function //////////////////////
//////////////////////////////////////////////////////////////////////
func BytesToString(data []byte) string {
	return string(data[:])
}

func ObtainFieldfromBytes(valAsbytes []byte, field string) string {
	valAsString := BytesToString(valAsbytes)
	startIndex := strings.Index(valAsString, field) + utf8.RuneCountInString(field) + 2
	if startIndex == -1 {
		fmt.Errorf("No such field")
	}

	endIndex := strings.Index(valAsString[startIndex:], ",\"") + startIndex
	if endIndex == -1 {
		endIndex := strings.Index(valAsString, "}")
		return valAsString[startIndex:endIndex]
	}
	return valAsString[startIndex:endIndex]
}

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// CreateUser - create a new user in the database
func (t *SimpleChaincode) initUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of argument, expecting 1.")
	}

	// ==== Input sanitation ====
	fmt.Println("- start init new user")

	aci := 0
	acndel := 0
	equity := 0.00
	callerName := args[0]

	// ==== Check if user already exists ====
	userAsByte, err := stub.GetState(callerName)
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if userAsByte != nil {
		fmt.Println("This user already exists: " + callerName)
		return shim.Error("This user already exists: " + callerName)
	}

	// ==== Create user object and marshal to JSON ====
	objectType := "user"
	user := &user{objectType, callerName, aci, acndel, equity}
	userJSONasBytes, err := json.Marshal(user)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save user to state ===
	err = stub.PutState(callerName, userJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("user " + callerName + " created")

	// ==== User saved. Return success ====
	fmt.Println("- end init user")

	return shim.Success(nil)

}

/*
ObjectType string  `json:"docType"` //docType is used to distinguish the various types of objects in state database
	ACNumber   string  `json:"ACNumber"`
	Owner      string  `json:"Owner"`
	Balance    float64 `json:"Balance"`
	Nonce      int     `json:"Nonce"`
*/
func (t *SimpleChaincode) initAC(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of argument, expecting 1.")
	}

	// ==== Input sanitation ====
	fmt.Println("- start init new account")

	balance := 0.00
	nonce := 0
	callerName := args[0]

	// ==== Check if user already exists ====
	userAsbyte, err := stub.GetState(callerName)
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if userAsbyte == nil {
		fmt.Println("This user has not yet created, please run initUser first!: " + callerName)
		return shim.Error("This user has not yet created, please run initUser first!: " + callerName)
	}

	//Create Account Number
	acNumberHashUpper := fnv.New32()
	acNumberHashLower := fnv.New32()

	acNumberHashLower.Write([]byte(callerName))
	fmt.Printf("CallerName Hash: %08x\n", acNumberHashLower.Sum32())

	//Obtain user's ACn
	userAsString := BytesToString(userAsbyte)
	fmt.Println("Converted to string: " + userAsString)
	aci := fmt.Sprintf("%04s", ObtainFieldfromBytes(userAsbyte, "ACi"))
	fmt.Println("ACi: " + aci)
	acNumberHashUpper.Write([]byte(aci))
	fmt.Printf("ACi Hash: %08x\n", acNumberHashUpper.Sum32())
	acNumber := fmt.Sprintf("%08x%08x", acNumberHashUpper.Sum32(), acNumberHashLower.Sum32())
	fmt.Println("acNumber: " + acNumber)

	// ==== Create ac object and marshal to JSON ====

	objectType := "ac"
	ac := &account{objectType, acNumber, callerName, balance, nonce}
	acJSONasBytes, err := json.Marshal(ac)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save ac to state ===
	err = stub.PutState(acNumber, acJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//Update user's ACn
	userToUpdate := user{}
	err = json.Unmarshal(userAsbyte, &userToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}
	userToUpdate.ACi++
	userJSONasBytes, _ := json.Marshal(userToUpdate)
	err = stub.PutState(callerName, userJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("ac " + acNumber + " from " + callerName + " created")

	// ==== User saved. Return success ====

	fmt.Println("- end init account")

	return shim.Success(nil)
}

func (t *SimpleChaincode) readState(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var name string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting username/acnumber")
	}

	name = args[0]
	valAsbytes, err := stub.GetState(name) //get the user from chaincode state
	if err != nil {
		return shim.Error("Failed to get state for " + name)
	} else if valAsbytes == nil {
		return shim.Error("User/Account does not exist: " + name)
	}

	fmt.Println(BytesToString(valAsbytes))
	return shim.Success(valAsbytes)
}

func (t *SimpleChaincode) delAC(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var acJSON account
	if len(args) != 1 {
		return shim.Error("Incorrect number of argument, expecting 1.")
	}
	ACnumber := args[0]

	//check if account exist
	valAsbytes, err := stub.GetState(ACnumber)
	if err != nil {
		return shim.Error("Failed to get state for " + ACnumber)
	} else if valAsbytes == nil {
		return shim.Error("Account does not exist: " + ACnumber)
	}

	// Obtain AC Balance
	err = json.Unmarshal([]byte(valAsbytes), &acJSON)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + ACnumber)
	}
	callerName := acJSON.Owner
	bal := acJSON.Balance
	err = stub.DelState(ACnumber) //remove the marble from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state:" + err.Error())
	}

	//update user ACndel
	userAsbytes, err := stub.GetState(callerName)
	userToUpdate := user{}
	err = json.Unmarshal(userAsbytes, &userToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}
	userToUpdate.ACnDel++
	userToUpdate.Equity -= bal
	userJSONasBytes, _ := json.Marshal(userToUpdate)
	err = stub.PutState(callerName, userJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("ac " + ACnumber + " from " + callerName + " deleted")

	return shim.Success(nil)
}

func (t *SimpleChaincode) delUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var jsonResp string
	var userJSON user
	if len(args) != 1 {
		return shim.Error("Incorrect number of argument, expecting 1.")
	}

	//get creator name
	callerName := args[0]

	//check if the user has created
	valAsbytes, err := stub.GetState(callerName)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + callerName + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"User does not exist in the system: " + callerName + "\"}"
		return shim.Error(jsonResp)
	}

	//Check if there are ac remaining belongs to the caller
	userAsString := BytesToString(valAsbytes)
	fmt.Println("Converted to string: " + userAsString)

	aciStart := strings.Index(userAsString, "ACi") + 5
	aciEnd := strings.Index(userAsString, ",\"ACn")
	fmt.Println("aci in string: " + userAsString[aciStart:aciEnd])
	aci, err := strconv.Atoi(userAsString[aciStart:aciEnd])

	acndelStart := strings.Index(userAsString, "ACnDel") + 8
	acndelEnd := strings.Index(userAsString, ",\"Equi")
	fmt.Println("acndel in string: " + userAsString[acndelStart:acndelEnd])
	acndel, err := strconv.Atoi(userAsString[acndelStart:acndelEnd])

	if err != nil {
		return shim.Error("Error to obtain ACi/ACndel")
	}

	if (aci - acndel) != 0 {
		fmt.Println("Number of ac of this user not zero, please run delUser first")
		return shim.Error("Number of ac of this user not zero, please run delUser first")
	}

	// Unmarshal
	err = json.Unmarshal([]byte(valAsbytes), &userJSON)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to decode JSON of: " + callerName + "\"}"
		return shim.Error(jsonResp)
	}

	err = stub.DelState(callerName) //remove the user from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state:" + err.Error())
	}

	fmt.Println("User " + callerName + " deleted")

	return shim.Success(nil)
}

func (t *SimpleChaincode) pay(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	// 0: senderAC		1: targetAC		2: amount		3: txNonce
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments, expecting 4.")
	}

	if args[0] == args[1] {
		return shim.Error("{Cannot transfer between the same account}")
	}

	// check if sender AC exist
	senderAC := args[0]
	sendACAsbytes, err := stub.GetState(senderAC)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + senderAC + "\"}")
	} else if sendACAsbytes == nil {
		return shim.Error("{\"Error\":\"Sender account does not exist in the system: " + senderAC + "\"}")
	}

	// check if target AC exist
	targetAC := args[1]
	targetACAsbytes, err := stub.GetState(targetAC)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + targetAC + "\"}")
	} else if targetACAsbytes == nil {
		return shim.Error("{\"Error\":\"Target account does not exist in the system: " + targetAC + "\"}")
	}

	// Retrieve transaction amount
	amount, err := strconv.ParseFloat(args[2], 64)
	if err != nil {
		return shim.Error("Error in converting amount to float number.")
	}

	// Check if sender account balance has enough money
	senderACAsString := BytesToString(sendACAsbytes)
	balStart := strings.Index(senderACAsString, "Balance") + 9
	balEnd := strings.Index(senderACAsString, ",\"Nonce")
	bal, err := strconv.ParseFloat(senderACAsString[balStart:balEnd], 64)
	if err != nil {
		return shim.Error("Error to obtain balance")
	} else if amount > bal {
		return shim.Error("Sender account does not have sufficient money")
	}

	// Retrieve TXnonce
	txNonce, err := strconv.Atoi(args[3])
	if err != nil {
		return shim.Error("Expecting Integral value of TX Nonce")
	}
	// Check if sender ACnonce match TXnonce
	nonceStart := strings.Index(senderACAsString, "Nonce") + 7
	nonceEnd := strings.Index(senderACAsString, ",\"Owner")
	nonce, err := strconv.Atoi(senderACAsString[nonceStart:nonceEnd])
	if err != nil {
		return shim.Error("Error to obtain Nonce value")
	} else if txNonce != nonce {
		fmt.Println("Sender account nonce mismatch with tx nonce")
		return shim.Error("Sender account nonce mismatch with tx nonce")
	}

	//Transfer Money & update Nonce and equity
	senderacToUpdate := account{}
	senderToUpdate := user{}
	targetacToUpdate := account{}
	targetToUpdate := user{}

	err = json.Unmarshal(sendACAsbytes, &senderacToUpdate)
	err = json.Unmarshal(targetACAsbytes, &targetacToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}

	senderAsbytes, err := stub.GetState(senderacToUpdate.Owner)
	targetAsbytes, err := stub.GetState(targetacToUpdate.Owner)
	if err != nil {
		return shim.Error("Error in obtaining sender or target users")
	} else if senderAsbytes == nil {
		return shim.Error("{\"Error\":\"Sender does not exist in the system\"}")
	} else if targetAsbytes == nil {
		return shim.Error("{\"Error\":\"Target user does not exist in the system\"}")
	}

	err = json.Unmarshal(senderAsbytes, &senderToUpdate)
	err = json.Unmarshal(targetAsbytes, &targetToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}

	if strings.Compare(senderacToUpdate.Owner, targetacToUpdate.Owner) != 0 {
		senderToUpdate.Equity -= amount
		targetToUpdate.Equity += amount
	}

	senderacToUpdate.Balance -= amount
	senderacToUpdate.Nonce++
	senderACJSONasBytes, _ := json.Marshal(senderacToUpdate)
	senderJSONasBytes, _ := json.Marshal(senderToUpdate)
	err = stub.PutState(senderAC, senderACJSONasBytes)
	err = stub.PutState(senderacToUpdate.Owner, senderJSONasBytes)

	targetacToUpdate.Balance += amount
	targetACJSONasBytes, _ := json.Marshal(targetacToUpdate)
	targetJSONasBytes, _ := json.Marshal(targetToUpdate)
	err = stub.PutState(targetAC, targetACJSONasBytes)
	err = stub.PutState(targetacToUpdate.Owner, targetJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("---------- Updated Balance ----------")
	fmt.Printf("%9s %25s: %v\n", "Sender AC", "("+senderAC+")", senderacToUpdate.Balance)
	fmt.Printf("%9s %25s: %v\n", "Sender", "("+senderacToUpdate.Owner+")", senderToUpdate.Equity)
	fmt.Printf("%9s %25s: %v\n", "Target AC", "("+targetAC+")", targetacToUpdate.Balance)
	fmt.Printf("%9s %25s: %v\n", "Target", "("+targetacToUpdate.Owner+")", targetToUpdate.Equity)
	fmt.Println("---------- End of Function ----------")

	return shim.Success(nil)

}

func (t *SimpleChaincode) addValue(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of argument, expecting 2.")
	}

	targetAC := args[0]
	amount, err := strconv.ParseFloat(args[1], 64)
	if err != nil {
		return shim.Error("Error in converting amount to float number.")
	}

	sysAsbytes, err := stub.GetState("SystemAC")
	targetACAsbytes, err := stub.GetState(targetAC)

	systemToUpdate := account{}
	targetacToUpdate := account{}

	err = json.Unmarshal(sysAsbytes, &systemToUpdate)
	err = json.Unmarshal(targetACAsbytes, &targetacToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}

	targetToUpdate := user{}
	targetAsbytes, err := stub.GetState(targetacToUpdate.Owner)
	if err != nil {
		return shim.Error("Error in obtaining sender or target users")
	} else if targetAsbytes == nil {
		return shim.Error("{\"Error\":\"Target user does not exist in the system\"}")
	}
	err = json.Unmarshal(targetAsbytes, &targetToUpdate)
	if err != nil {
		return shim.Error(err.Error())
	}

	systemToUpdate.Balance -= amount
	targetacToUpdate.Balance += amount
	targetToUpdate.Equity += amount

	sysJSONasBytes, _ := json.Marshal(systemToUpdate)
	targetacJSONasBytes, _ := json.Marshal(targetacToUpdate)
	targetJSONasBytes, _ := json.Marshal(targetToUpdate)

	err = stub.PutState("SystemAC", sysJSONasBytes)
	err = stub.PutState(targetAC, targetacJSONasBytes)
	err = stub.PutState(targetacToUpdate.Owner, targetJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Printf("Amount of %v has been added to %s\n", amount, targetAC)
	fmt.Println("---------- Updated Balance ----------")
	fmt.Printf("%9s %25s: %v\n", "Target AC", "("+targetAC+")", targetacToUpdate.Balance)
	fmt.Printf("%9s %25s: %v\n", "Target", "("+targetacToUpdate.Owner+")", targetToUpdate.Equity)
	fmt.Println("---------- End of Function ----------")
	return shim.Success(nil)
}

func (t *SimpleChaincode) getHistory(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//	0
	//	Account No.
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	acnumber := args[0]

	fmt.Printf("########### Start getHistory: %s ###########\n", acnumber)

	resultsIterator, err := stub.GetHistoryForKey(acnumber)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	if buffer.String() == "[]" {
		fmt.Println("Account does not exist in the system.")
		return shim.Error("{\"Error\":\"Account does not exist in the system\"}")
	}

	fmt.Printf("------------- getHistory returning -------------\n%s\n", buffer.String())
	fmt.Println("------------- getHistory complete --------------")

	return shim.Success(buffer.Bytes())

}
