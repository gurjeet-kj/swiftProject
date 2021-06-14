//
//  main.swift
//  SwiftProject
//
//  Created by Gurjeet KJ on 6/10/21.
//  Copyright © 2021 Gurjeet Kaur Jathaul. All rights reserved.
//


import Foundation


class CustomerInfo: Codable {
    var customeName: String
    var contactNumber: String
    var fullAddress: String
    var customerPassword: String
    
    var accounts: BankAccountTypes?
    
    init(customeName: String, contactNumber: String, fullAddress: String, customerPassword: String) {
        self.customeName = customeName
        self.contactNumber = contactNumber
        self.fullAddress = fullAddress
        self.customerPassword = customerPassword
        
    }
    func addBankAccountTypes(accs: BankAccountTypes) {
        accounts = accs
    }
}

class Customers: Codable {
    var customers: [CustomerInfo]
    
    init(custs: [CustomerInfo]) {
        self.customers = custs
    }
}

class BankAccountTypes: Codable {
    var savingsAcc: SavingsAccount?
    var fixedDepositAcc: FixedDepositAccount?
    
    init(savAcc: SavingsAccount? = nil, fixAcc: FixedDepositAccount? = nil) {
        self.savingsAcc = savAcc
        self.fixedDepositAcc = fixAcc
    }
}

class BankAccount: Codable {
    var accountNumber: String
    var accountBalance: Double
    
    init(acNo: String, acBalance: Double) {
        self.accountNumber = acNo
        self.accountBalance = acBalance
    }
         
    private enum CodingKeys: String, CodingKey {
        case accountNumber
        case accountBalance
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(accountBalance, forKey: .accountBalance)
    }
    
    
    // Functions to add balance in account
    func addAmountToBalance(amountToAdd: Double) -> Double {
        accountBalance += amountToAdd
        return accountBalance
    }
    // Functions to subtract balance from account
    func subtractAmountFromBalance(amountToDeduct: Double) -> Double {
        accountBalance -= amountToDeduct
        return accountBalance
    }
}


class SavingsAccount: BankAccount {
    var minBalance: Double
    var interestRate: Double
    
    init(acNo: String, acBalance: Double, acMinimumBalance: Double, acInterestRate: Double) {
        self.minBalance = acMinimumBalance
        self.interestRate = acInterestRate
        
        super.init(acNo: acNo, acBalance: acBalance)
    }
    
    private enum CodingKeys: String, CodingKey {
        case minBalance
        case interestRate
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minBalance, forKey: .minBalance)
        try container.encode(interestRate, forKey: .interestRate)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minBalance = try container.decode(Double.self, forKey: .minBalance)
        interestRate = try container.decode(Double.self, forKey: .interestRate)
        try super.init(from: decoder)
    }
}

class FixedDepositAccount: BankAccount {
    var fixedDepositDuration: Int
    var interestRate: Double
    
    init(acNo: String, acBalance: Double, fdDuration: Int, acInterestRate: Double) {
        self.fixedDepositDuration = fdDuration
        self.interestRate = acInterestRate
        
        super.init(acNo: acNo, acBalance: acBalance)
    }
    
    private enum CodingKeys: String, CodingKey {
        case fixedDepositDuration
        case interestRate
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fixedDepositDuration, forKey: .fixedDepositDuration)
        try container.encode(interestRate, forKey: .interestRate)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fixedDepositDuration = try container.decode(Int.self, forKey: .fixedDepositDuration)
        interestRate = try container.decode(Double.self, forKey: .interestRate)
        try super.init(from: decoder)
    }
}



// All customers
var customers: Customers?
// Logged in customers
var loggedInCustomer: CustomerInfo?

///////////////////All Functions starts from here/////////////////////////////////

let savingMinBal = Double(100)
let savingIntRate = Double(5)
let fdIntRate = Double(10)
var lastAccountNumber = 0

func registerCustomers() -> [CustomerInfo] {
    var customers = [CustomerInfo]()
    var yesorno = false
    repeat {
        customers.append(registerSingleCustomer())
        print("\nWould You Like To Create A New Account For The Customer? yes/no")
        yesorno = readLine()! == "yes"
    }
    while yesorno

    return customers
}

func registerSingleCustomer() -> CustomerInfo {
    print("Enter Customer Name: ")
    let customeName = readLine()!
    print("Enter Customer Password: ")
    let pass = readLine()!
    print("Enter Mobile or Phone Number: ")
    let contactNumber = readLine()!
    print("Enter Your Address: ")
    let fullAddress = readLine()!

    let customer = CustomerInfo(customeName: customeName, contactNumber: contactNumber, fullAddress: fullAddress, customerPassword: pass)
    customer.addBankAccountTypes(accs: letAddBankAccountTypes())

    print("\n      ------------ Successfully Registered ------------      ")

    return customer
}

func letAddBankAccountTypes(accs: BankAccountTypes? = nil) -> BankAccountTypes {
    
    var bankAccountTypes = BankAccountTypes()
    if let _bankAccountTypes = accs {
        bankAccountTypes = _bankAccountTypes
    }

    repeat {
        print("\nWhat Kind Of Account You Would Like to Open?\n1 - Fixed Deposit account\n2 - Saving account")
        let choice = Int(readLine()!)!

        switch choice {
            case 1:
               // Fixed deposit account
                let fdAcc = createFdAcc()
                bankAccountTypes.fixedDepositAcc = fdAcc

            case 2:
                // Saving account
                let savAcc = createSavingAcc()
                bankAccountTypes.savingsAcc = savAcc

            default:
                // Invalid Option
                print("Sorry, Please Enter Valid Option.\n")
        }

        print("\nWould You Like To Add More Bank Account? yes/no")
    }
    while readLine()! == "yes"

    return bankAccountTypes
}

func customerLogin() -> CustomerInfo? {
    var customer: CustomerInfo?
    var yesorno = false
    repeat {
        customer = tryLogin()
        if let cust = customer {
            print("\n      ------------ Welcome \(cust.customeName) To Our MADT Bank ------------      ")
            yesorno = false
        }
        else {
            print("Wrong Login Credentials Entered. Like to try again? yes/no")
            yesorno = readLine()! == "yes"
        }
    }
    while yesorno

    return customer
}

func tryLogin() -> CustomerInfo? {
    print("Enter Customer Name:")
    let customeName = readLine()!
    print("Enter Your Password:")
    let pass = readLine()!

   if let custs = customers?.customers {
        for cust in custs {
            if cust.customeName.lowercased() == customeName.lowercased(), cust.customerPassword.lowercased() == pass.lowercased() {
                // code to login
                return cust
            }
        }
    }
    return nil
}

func getAvailableAccountNumbers() -> [String] {
    var accountNumbers = [String]()
    
    if let allCustomers = customers {
        
        for cust in allCustomers.customers {
          
            if let _savAcc = cust.accounts?.savingsAcc {
                accountNumbers.append(_savAcc.accountNumber)
            }
            
            if let _fdAcc = cust.accounts?.fixedDepositAcc {
                accountNumbers.append(_fdAcc.accountNumber)
            }
        }
        
    }
    return accountNumbers
}

func updateCustomerProfileDetails(cust: CustomerInfo) -> CustomerInfo {
    
    print("Update your desire details in customer profile:")
    print("1 - Customer Name: \(cust.customeName)\n2 - Customer Mobile/Phone Number: \(cust.contactNumber)\n3 - Customer Address: \(cust.fullAddress)\n4 - Customer Password: \(cust.customerPassword)\n5 - Go back to previous menu")
    
    var customerSelectOption = -1
    repeat{
        
        customerSelectOption = Int(readLine()!)!
        switch customerSelectOption {
        
                
            case 1: // change customeName
                print("Enter New Updated Name: ")
                if let customeName = readLine() {
                    cust.customeName = customeName
                }
                
            case 2: // change phone number
                print("Enter New Contact Number: ")
                if let contactNumber = readLine() {
                    cust.contactNumber = contactNumber
                }
                
            case 3: // change full fullAddress
                print("Enter New Updated Address: ")
                if let addressCity = readLine() {
                    cust.fullAddress = addressCity
                }
                
            case 4: // change customerPassword
                print("Enter New Password: ")
                if let pass = readLine() {
                    cust.customerPassword = pass
                }
           
           case 5: // go back go previous menu
                print("")
                 
            default:
                print("Invalid Number Entered!")
                customerSelectOption = -1
            
        }
        
        
    } while(customerSelectOption == -1)
    
    return cust
}

func updateLoggedInCustomer(cust: CustomerInfo) {
    
    for i in 0..<customers!.customers.count {
        if customers!.customers[i].customeName == cust.customeName {
            customers!.customers[i] = cust
        }
    }
    
    savingIntoFile(of: readingFromFileInStringFormat(of: customers!))
    
}

// creating bank account related functions

func generateNextAccountNumber() -> String {
    var acNo = 0
    var lastAccNo = lastAccountNumber
    let savedData = getSavedData()
    if savedData.initialBanking {
        acNo = Int(String(format: "%05d", 1))!
    }
    else {
        let cust = savedData.cust
        if let fd = cust!.customers.last!.accounts!.fixedDepositAcc {
            if Int(fd.accountNumber)! > lastAccNo {
                lastAccNo = Int(fd.accountNumber)!
            }
        }
                
        if let sav = cust!.customers.last!.accounts!.savingsAcc {
            if Int(sav.accountNumber)! > lastAccNo {
                lastAccNo = Int(sav.accountNumber)!
            }
        }
    }
    acNo = lastAccNo + 1
    lastAccountNumber = acNo
    return String(format: "%05d", acNo)
    
    
   
}



func createSavingAcc() -> SavingsAccount {
    let acNo = generateNextAccountNumber()
    print("Minimum Balance Should Be More Than : \(savingMinBal) And Interest Rate : \(savingIntRate)%")

    var accBal = Double(0)
    var rep = false
    repeat {
        print("Enter Your Start Up Balance, You Like To Deposit : ")
        accBal = Double(readLine()!)!
        if accBal > savingMinBal {
            rep = false
        }
        else {
            print("Please Enter Amount More Than \(savingMinBal)")
            rep = true
        }
    }
    while rep

    return SavingsAccount(acNo: acNo, acBalance: accBal, acMinimumBalance: savingMinBal, acInterestRate: savingIntRate)
}

func createFdAcc() -> FixedDepositAccount {
    let acNo = generateNextAccountNumber()
    print("Enter Amount To Add In Fixed Deposit Account : ")
    let accBal = Double(readLine()!)!
    print("For How Many Months, You Would Like To Deposit : ")
    let fdDuration = Int(readLine()!)!

    print("Interest Rate For Fixed Deposit : \(fdIntRate)%")

    return FixedDepositAccount(acNo: acNo, acBalance: accBal, fdDuration: fdDuration, acInterestRate: fdIntRate)
}

// functions regarding transactions
func displayBalance(accs: BankAccountTypes?) {
    if let accounts = accs {
        
        if let savAcc = accounts.savingsAcc {
            print("Balance Of Your Savings Account : \(String(format: "%.2f", savAcc.accountBalance))")
        }
        
        if let fdAcc = accounts.fixedDepositAcc {
            print("Balance Of Your Fixed Deposit Account : \(String(format: "%.2f", fdAcc.accountBalance))")
        }
        
    }
}

func depositAmount(accs: BankAccountTypes?, money: Double) {
    if let accounts = accs {
        
        var savAcc: SavingsAccount?
        var fdAcc: FixedDepositAccount?
        
        
        if let _fdAcc = accounts.fixedDepositAcc {
            fdAcc = _fdAcc
        }
        if let _savAcc = accounts.savingsAcc {
            savAcc = _savAcc
        }
        
        
        
        
        var customerSelectOption = -1
        repeat {
            
        print("\nSelect Your Account Where You Like To Deposite Money?\n1 - Fixed Deposit Account\n2 - Savings Account\n0 - To Go Back To Previous Menu")
            customerSelectOption = Int(readLine()!)!
            
            switch customerSelectOption {
                case 0: // go back to previous menu
                    print("")
                    
                case 1: // FD account
                    let newBal = fdAcc?.addAmountToBalance(amountToAdd: money)
                    print("New Balance In Fixed Deposit account : \(String(describing: newBal))")
                    
                case 2: // savings account
                    let newBal = savAcc?.addAmountToBalance(amountToAdd: money)
                    print("New Balance In Savings Account  : \(String(describing: newBal))")
                                        
                default:
                    print("Invalid Number Entered! Please Enter Again!")
                    customerSelectOption = -1
            }
            
        } while(customerSelectOption == -1)
        
    }
}

func withdrawAmount(accs: BankAccountTypes?, money: Double) {
    if let accounts = accs {
        
        var savAcc: SavingsAccount?
        var fdAcc: FixedDepositAccount?
        
        var str = "\nFrom Your Which Account You Like To Withdraw Amount?\n"
        
        if let _fdAcc = accounts.fixedDepositAcc {
            str += "1 - Fixed Deposit Account\n"
            fdAcc = _fdAcc
        }
        
        if let _savAcc = accounts.savingsAcc {
            str += "2 - Savings Account\n"
            savAcc = _savAcc
        }
        
        
        str += "0 - To Go Back To Previous Menu"
        
        var customerSelectOption = -1
        repeat {
            
            print(str)
            customerSelectOption = Int(readLine()!)!
            
            switch customerSelectOption {
                case 0: // go back to previous menu
                    print("")
                    
                case 1: // Fixed Deposit account
                    if let _fdAcc = fdAcc {
                        if _fdAcc.accountBalance > money {
                            print("You Withdraw Amount : \(money) ")
                            print("New Balance In Fixed Deposit Account : \(_fdAcc.subtractAmountFromBalance(amountToDeduct: money))")
                        }
                    }
                    
                case 2: // Savings account
                    if let _savAcc = savAcc {
                        if _savAcc.accountBalance > money {
                            print("You Withdraw Amount : \(money) ")
                            print("New Balance In Savings Account : \(_savAcc.subtractAmountFromBalance(amountToDeduct: money))")
                        }
                    }
                    
                    
                default:
                    print("Invalid input. please try again")
                    customerSelectOption = -1
            }
            
        } while(customerSelectOption == -1)
        
        
    }
}

func transferAmountToOtherAccount(accs: BankAccountTypes?) {
    if let accounts = accs {
        
        var savAcc: SavingsAccount?
        var fdAcc: FixedDepositAccount?
        
        var str = "From Your Which Account, You Like To Transfer?\n"
         if let _fdAcc = accounts.fixedDepositAcc {
            str += "1 - Fixed Deposit Account\n"
            fdAcc = _fdAcc
        }
        
        
        if let _savAcc = accounts.savingsAcc {
            str += "2 - Savings Account\n"
            savAcc = _savAcc
        }
        
       
        str += "0 - To Go Back To Previous Menu"
        
        var customerSelectOption = -1
        repeat {
            
            print(str)
            customerSelectOption = Int(readLine()!)!
            
            switch customerSelectOption {
                case 0: // go back to previous menu
                    print("")
                    
                case 1: // FD account
                    if let _fdAcc = fdAcc {
                        print("You Have \(String(format: "%.2f", _fdAcc.accountBalance)) Amount In Your Fixed Deposite Account.\nWhat Amount You Would Like To Transfer?")
                        let money = Double(readLine()!)!
                        
                        if money < _fdAcc.accountBalance {
                            addMoneyToOtherAccountNumber(money: money)
                            let amount = _fdAcc.subtractAmountFromBalance(amountToDeduct: money)
                            print("New balance in \(loggedInCustomer!.customeName)'s Fixed Deposit account is \(amount)")
                            print("Transfer Successful !")
                        }
                    }
                case 2: // savings account
                    if let _savAcc = savAcc {
                        print("You Have \(String(format: "%.2f", _savAcc.accountBalance)) Amount In Your Savings Account.\nWhat Amount You Would Like To Transfer?")
                        let money = Double(readLine()!)!
                        
                        if money < _savAcc.accountBalance {
                            addMoneyToOtherAccountNumber(money: money)
                            let amount = _savAcc.subtractAmountFromBalance(amountToDeduct: money)
                            print("New balance in \(loggedInCustomer!.customeName)'s Savings account is \(amount)")
                            print("Transfer Successful !")
                        }
                    }
                    
                default:
                    print("Invalid input. please try again")
                    customerSelectOption = -1
            }
        } while(customerSelectOption == -1)
    }
}

func addMoneyToOtherAccountNumber(money: Double) {
    
    print("\nEnter The Account Number In Which You Like To Transfer/Send Amount :")
    print("Available Account Numbers In Bank System Are : \(getAvailableAccountNumbers())")
    let accToTransfer = readLine()!
    
    for item in customers!.customers {
        if let acc = item.accounts?.savingsAcc {
            if acc.accountNumber == accToTransfer {
                let amount = acc.addAmountToBalance(amountToAdd: money)
                print("New Balance In \(item.customeName)'s Savings Account Now : \(amount)")
                break
            }
        }
        
        if let acc = item.accounts?.fixedDepositAcc {
            if acc.accountNumber == accToTransfer {
                let amount = acc.addAmountToBalance(amountToAdd: money)
                print("New Balance In \(item.customeName)'s Fixed Deposit Account : \(amount)")
                break
            }
        }
    }
}


//All functions for loggedin customers's banking process
func loggedInCustomerBanking() {
    var customerSelectOption = -1
    repeat {
print("\n      ------------ Enter Below Option To Perform Banking ------------      ")
print("\n1 - Deposit Amount\n2 - Withdraw Amount\n3 - Display Total Balance\n4 - Transfer Money to Other Account\n5 - Change Customer Profile Details\n6 - Add New Bank Account\n7 - Logout")
        
        customerSelectOption = Int(readLine()!)!
        
        switch customerSelectOption {
            case 1: // Deposit money
                print("Enter The Amount To Deposit : ")
                let amount = Double(readLine()!)!
                depositAmount(accs: loggedInCustomer!.accounts, money: amount)
                
                updateCustomerDataInFile()
                customerSelectOption = -1

            case 2: // withdraw amount
                print("Enter The Amount To Withdraw : ")
                let amount = Double(readLine()!)!
                withdrawAmount(accs: loggedInCustomer!.accounts, money: amount)
                updateCustomerDataInFile()
                customerSelectOption = -1

            case 3: // Display current balance
                displayBalance(accs: loggedInCustomer!.accounts)
                customerSelectOption = -1     // set -1 to go back

           
            case 4: // transfer amount to other accounts
                transferAmountToOtherAccount(accs: loggedInCustomer!.accounts)
                updateCustomerDataInFile()
                customerSelectOption = -1

           
            case 5: // change customer profile details
                loggedInCustomer = updateCustomerProfileDetails(cust: loggedInCustomer!)
                updateCustomerDataInFile()
                customerSelectOption = -1

            case 6: // add a new bank account
                let accounts = loggedInCustomer!.accounts
                loggedInCustomer!.addBankAccountTypes(accs: letAddBankAccountTypes(accs: accounts))
                updateCustomerDataInFile()
                customerSelectOption = -1
            
            case 7: // logout
                loggedInCustomer = nil
                print("\n      ------------ You Have Logged Out Successfully! ------------      \n")

            default:
                print("Incorrect Number Entered!")
                customerSelectOption = -1
        }
        
    } while(customerSelectOption == -1)

}

func updateCustomerDataInFile() {
    var jsonStr = ""
    for i in 0..<customers!.customers.count {
        if customers!.customers[i].customeName == loggedInCustomer!.customeName {
            customers!.customers[i] = loggedInCustomer!
        }
    }
    jsonStr = readingFromFileInStringFormat(of: customers!)
    savingIntoFile(of: jsonStr)
}

// function to show all data
func showCustomersFromJsonFile() {
    let json = readingFromFileInStringFormat(of: customers!)
    print(json)
}


//////////////////////File system main functions starts from here////////////////////////

let madtDirectoryName = "SwiftProject"
let madtCustomersFilename = "customer.json"

extension URL {
    static func getOrCreateFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first
        {
            // Construct a URL with desired folder
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // folder creation
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    
                    print(error.localizedDescription)
                    return nil
                }
            }
            return folderURL
        }
        // If directory not found
        return nil
    }
}

// this will be called at initialization of the program
func getSavedData() -> (cust: Customers?, initialBanking: Bool) {
    if let customer = readJsonFile() {
        return (customer, false)
    }

    return (nil, true)
}

// function to get data in string format from file
func readingFromFileInStringFormat(of obj: Customers) -> String {
    do {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted]
        let jsonData = try jsonEncoder.encode(obj)
        if let jsonDataInString = String(data: jsonData, encoding: String.Encoding.utf8) {
            // print(jsonDataInString)
            return jsonDataInString
        }
    } catch {}
    return ""
}

// function to save data in file
func savingIntoFile(of jsonString: String) {
    if let path = URL.getOrCreateFolder(folderName: madtDirectoryName) {
        let filePath = path.appendingPathComponent(madtCustomersFilename)
        print("Saved Customer Details At Location : \(filePath)")
              do {
                   try jsonString.write(to: filePath, atomically: true, encoding: .utf8) //writing in file
               } catch {
                   print("Technical Error In Writing File")
               }
       
    }
}


// function to read data from file
func readJsonFile() -> Customers? {
    if let path = URL.getOrCreateFolder(folderName: madtDirectoryName) {
        let filePath = path.appendingPathComponent(madtCustomersFilename)
        let data = NSData(contentsOf: filePath)

        do {
            if let dataJson = data as Data? {
                let cust = try JSONDecoder().decode(Customers.self, from: dataJson)
                return cust
            }
        } catch {
            print("")// if file is empty initial then error in reading file so reaches here
        }
    }

    return nil
}

///////////////////Main part///////////////////////////////

var savedData = getSavedData() // Fetch saved data from file

// function to check if system start with no data in it then it need atleast one customer account to operate
if savedData.initialBanking {

print("\n      ------------ WELCOME TO MADT BANK ------------      ")
    print("\nRegsiter Customer Account To Start Banking System : \n")
        
    let users = registerCustomers() // register customer
       
    customers = Customers(custs: users)  // created  object of Customer
    var jsonStr = ""
    
    if let data = customers {
        jsonStr = readingFromFileInStringFormat(of: data)  // initially get the data from file
    }
    
    savingIntoFile(of: jsonStr)  // save Json data into file
}
else {
    customers = savedData.cust // if data exist in file
}



// Show main menu to registered customers
print("\n      ------------ START BANKING TRANSACTIONS WITH YOUR MADT BANK ------------      ")
print("\nSelect Below Choice For Banking:")

// loop if user enters invalid action digit
var customerSelectOption = -1
repeat {
    print("1 - Register New Customer Account\n2 - Login Into Existing Customer Account\n3 - Display Saved Customers Data\n4 - Exit\n")
    customerSelectOption = Int(readLine()!)!
    
    // switch to check user input action
    switch customerSelectOption {
       case 1: // register users
            let users = registerCustomers()
            for user in users {
                customers?.customers.append(user)
            }
            var jsonStr = ""
            if let data = customers {
                jsonStr = readingFromFileInStringFormat(of: data)
            }
            
            savingIntoFile(of: jsonStr) // save data to file
            
            customerSelectOption = -1 // reset to goto main menu again
            
        case 2: // Login
            loggedInCustomer = customerLogin()
                        
            if let _ = loggedInCustomer {
                loggedInCustomerBanking() // showing loggedin customers menu
            }
            
            customerSelectOption = -1 // reset to goto main menu
                    
        case 3: // Show all data
            showCustomersFromJsonFile()
            customerSelectOption = -1
        
        case 4: // exit from loop
            print("\n      ------------ THANK YOU FOR USING MADT BANK ------------      ")
                        
        default: // invalid action
            print("Please Enter Valid Option Number!")
            customerSelectOption = -1
    }
    
} while(customerSelectOption == -1)   // untill customer wants to do banking transactions
