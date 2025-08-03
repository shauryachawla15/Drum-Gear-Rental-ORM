USE drum_rental;

INSERT INTO Customer VALUES 
(1, 'Shaurya', 'Chawla', 'shauryachawla15@email.com');

INSERT INTO Product VALUES 
(1, 'Drum Kit', 'Yamaha', 'Excellent', 45.00),
(2, 'Snare Drum', 'Pearl', 'Good', 20.00);

INSERT INTO Rental VALUES 
(1, 1, 1, '2025-07-01', '2025-07-03', 135.00),
(2, 1, 2, '2025-07-04', '2025-07-05', 40.00);

INSERT INTO Payment VALUES 
(1, 1, 135.00, 'Credit Card', 'Paid'),
(2, 2, 40.00, 'UPI', 'Paid');
