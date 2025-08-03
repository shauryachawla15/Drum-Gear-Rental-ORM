CREATE DATABASE IF NOT EXISTS drum_rental;
USE drum_rental;

CREATE TABLE Customer (
  CustomerID INT PRIMARY KEY,
  FirstName VARCHAR(100),
  LastName VARCHAR(100),
  Email VARCHAR(100)
);

CREATE TABLE Product (
  ProductID INT PRIMARY KEY,
  Type VARCHAR(50),
  Brand VARCHAR(100),
  ConditionStatus VARCHAR(50),
  PricePerDay DECIMAL(10,2)
);

CREATE TABLE Rental (
  RentalID INT PRIMARY KEY,
  CustomerID INT,
  ProductID INT,
  StartDate DATE,
  EndDate DATE,
  TotalPrice DECIMAL(10,2),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE Payment (
  PaymentID INT PRIMARY KEY,
  RentalID INT,
  Amount DECIMAL(10,2),
  Method VARCHAR(50),
  Status VARCHAR(20),
  FOREIGN KEY (RentalID) REFERENCES Rental(RentalID)
);
