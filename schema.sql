-- Table: Customer – Stores customer personal information
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(255),
    Address TEXT,
    CCCD_Passport VARCHAR(255) UNIQUE NOT NULL,  -- Encrypted at application layer
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(50),
    Nationality VARCHAR(100),
    Occupation VARCHAR(255),
    BranchID INTEGER REFERENCES Branch(BranchID),  -- Assuming Branch table exists
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Active', 'Suspended', 'Inactive'))
);

-- Table: BankAccount – Stores customer banking accounts
CREATE TABLE BankAccount (
    AccountID SERIAL PRIMARY KEY,
    CustomerID INTEGER NOT NULL REFERENCES Customer(CustomerID),
    AccountType VARCHAR(255) NOT NULL CHECK (AccountType IN ('Checking', 'Savings', 'Credit')),
    AccountNumber VARCHAR(255) UNIQUE NOT NULL,  -- Encrypted at application layer
    Balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    OpenDate DATE NOT NULL,
    InterestRate DECIMAL(5, 2),
    CreditLimit DECIMAL(15, 2),
    BranchID INTEGER REFERENCES Branch(BranchID),
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Active', 'Frozen', 'Closed'))
);

-- Table: Card – Stores banking card information
CREATE TABLE Card (
    CardID SERIAL PRIMARY KEY,
    AccountID INTEGER NOT NULL REFERENCES BankAccount(AccountID),
    CardNumber VARCHAR(255) UNIQUE NOT NULL,  -- Encrypted at application layer
    CardType VARCHAR(255) NOT NULL CHECK (CardType IN ('Debit', 'Credit', 'Prepaid')),
    ExpiryDate DATE NOT NULL,
    CVV VARCHAR(255) NOT NULL,  -- Encrypted at application layer
    IssueDate DATE NOT NULL,
    SpendingLimit DECIMAL(15, 2),
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Active', 'Blocked', 'Expired'))
);

-- Table: Merchant – Stores merchant information
CREATE TABLE Merchant (
    MerchantID SERIAL PRIMARY KEY,
    MerchantName VARCHAR(255) NOT NULL,
    Category VARCHAR(255),
    Location TEXT,
    MCC VARCHAR(4),
    ContactInfo TEXT,
    RiskScore INTEGER NOT NULL DEFAULT 0 CHECK (RiskScore >= 0 AND RiskScore <= 100)
);

-- Table: Device – Tracks devices used by customers
CREATE TABLE Device (
    DeviceID SERIAL PRIMARY KEY,
    CustomerID INTEGER NOT NULL REFERENCES Customer(CustomerID),
    DeviceType VARCHAR(255) NOT NULL CHECK (DeviceType IN ('Mobile', 'Desktop', 'Tablet')),
    DeviceFingerprint VARCHAR(255) UNIQUE NOT NULL,
    IPAddress VARCHAR(255),
    LastUsed TIMESTAMP,
    OS VARCHAR(255),
    AppVersion VARCHAR(50),
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Trusted', 'Suspicious', 'Blocked')),
    RiskTag VARCHAR(255) NOT NULL CHECK (RiskTag IN ('Low', 'Medium', 'High'))
);

-- Table: AuthenticationLog – Logs authentication events for transactions
CREATE TABLE AuthenticationLog (
    AuthLogID SERIAL PRIMARY KEY,
    CustomerID INTEGER NOT NULL REFERENCES Customer(CustomerID),
    TransactionID INTEGER REFERENCES PaymentTransaction(TransactionID),
    AuthType VARCHAR(255) NOT NULL CHECK (AuthType IN ('OTP', 'Biometric', 'Password')),
    AuthDate TIMESTAMP NOT NULL,
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Success', 'Failed', 'Pending')),
    OTPCode VARCHAR(255),  -- Encrypted at application layer
    BiometricData VARCHAR(255),  -- Encrypted at application layer
    DeviceID INTEGER REFERENCES Device(DeviceID),
    Location VARCHAR(255),
    RiskTag VARCHAR(255) NOT NULL CHECK (RiskTag IN ('Low', 'Medium', 'High'))
);

-- Table: PaymentTransaction – Stores all payment transaction records
CREATE TABLE PaymentTransaction (
    TransactionID SERIAL PRIMARY KEY,
    AccountID INTEGER NOT NULL REFERENCES BankAccount(AccountID),
    CardID INTEGER REFERENCES Card(CardID),
    MerchantID INTEGER NOT NULL REFERENCES Merchant(MerchantID),
    Amount DECIMAL(15, 2) NOT NULL,
    TransactionDate TIMESTAMP NOT NULL,
    TransactionType VARCHAR(255) NOT NULL CHECK (TransactionType IN ('Online', 'POS', 'ATM', 'Transfer', 'Refund')),
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Completed', 'Pending', 'Declined')),
    DeviceID INTEGER REFERENCES Device(DeviceID),
    AuthLogID INTEGER REFERENCES AuthenticationLog(AuthLogID),
    TransactionFee DECIMAL(15, 2),
    DestinationAccount VARCHAR(255),
    RiskTag VARCHAR(255) NOT NULL CHECK (RiskTag IN ('Low', 'Medium', 'High'))
);

-- Table: FraudAlert – Tracks potential fraud alerts
CREATE TABLE FraudAlert (
    AlertID SERIAL PRIMARY KEY,
    TransactionID INTEGER REFERENCES PaymentTransaction(TransactionID),
    CustomerID INTEGER NOT NULL REFERENCES Customer(CustomerID),
    DeviceID INTEGER REFERENCES Device(DeviceID),
    AuthLogID INTEGER REFERENCES AuthenticationLog(AuthLogID),
    AlertType VARCHAR(255) NOT NULL,
    AlertDate TIMESTAMP NOT NULL,
    RiskScore INTEGER NOT NULL CHECK (RiskScore >= 0 AND RiskScore <= 100),
    Status VARCHAR(255) NOT NULL CHECK (Status IN ('Open', 'Resolved', 'False')),
    Handler VARCHAR(255),
    ResolutionTime TIMESTAMP,
    RiskTag VARCHAR(255) NOT NULL CHECK (RiskTag IN ('Low', 'Medium', 'High'))
);

-- Indexes for performance optimization
CREATE INDEX idx_customer_branchid ON Customer(BranchID);
CREATE INDEX idx_account_branchid ON BankAccount(BranchID);
CREATE INDEX idx_transaction_destinationaccount ON PaymentTransaction(DestinationAccount);

-- Column comments
COMMENT ON COLUMN Customer.Gender IS 'Gender of the customer';
COMMENT ON COLUMN Customer.Nationality IS 'Customer\'s nationality';
COMMENT ON COLUMN Customer.Occupation IS 'Customer\'s occupation';
COMMENT ON COLUMN BankAccount.InterestRate IS 'Interest rate for savings accounts';
COMMENT ON COLUMN BankAccount.CreditLimit IS 'Credit limit for credit accounts';
COMMENT ON COLUMN Card.IssueDate IS 'Card issue date';
COMMENT ON COLUMN Card.SpendingLimit IS 'Maximum spending limit on card';
COMMENT ON COLUMN Merchant.MCC IS 'Merchant Category Code';
COMMENT ON COLUMN Merchant.ContactInfo IS 'Merchant contact information';
COMMENT ON COLUMN Device.OS IS 'Operating system of the device';
COMMENT ON COLUMN Device.AppVersion IS 'Banking app version on device';
COMMENT ON COLUMN AuthenticationLog.Location IS 'Login location based on IP';
COMMENT ON COLUMN PaymentTransaction.TransactionFee IS 'Fee applied to transaction';
COMMENT ON COLUMN PaymentTransaction.DestinationAccount IS 'Receiving account in transfer';
COMMENT ON COLUMN FraudAlert.Handler IS 'Person who handled the fraud alert';
COMMENT ON COLUMN FraudAlert.ResolutionTime IS 'Time fraud alert was resolved';
