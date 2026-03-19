-- ========================================
-- SAMPLE DATA INSERTION
-- Blood Bank Management System
-- ========================================

-- Insert Blood Banks
INSERT INTO Blood_Bank (bank_name, address, contact_number, email, city, state) VALUES
('City Blood Bank', '123 Main Street, Downtown', '9876543210', 'contact@citybloodbank.com', 'Mumbai', 'Maharashtra'),
('Central Blood Center', '456 Park Avenue', '9876543211', 'info@centralblood.com', 'Delhi', 'Delhi'),
('Red Cross Blood Bank', '789 Gandhi Road', '9876543212', 'redcross@bloodbank.com', 'Bangalore', 'Karnataka'),
('Apollo Blood Bank', '321 Hospital Lane', '9876543213', 'apollo.blood@hospital.com', 'Chennai', 'Tamil Nadu'),
('Lifeline Blood Bank', '654 Medical Street', '9876543214', 'lifeline@blood.org', 'Pune', 'Maharashtra');

-- Insert Donors
INSERT INTO Donor (donor_name, blood_group, medical_report, address, contact_number, email, date_of_birth, gender, last_donation_date, is_eligible) VALUES
('Rajesh Kumar', 'O+', 'Healthy, No medical conditions', '12 Nehru Nagar', '8765432101', 'rajesh.k@email.com', '1990-05-15', 'M', '2025-10-01', TRUE),
('Priya Sharma', 'A+', 'Good health, Regular donor', '45 Lake View', '8765432102', 'priya.s@email.com', '1988-08-22', 'F', '2025-11-15', TRUE),
('Amit Patel', 'B+', 'Healthy donor', '78 Green Park', '8765432103', 'amit.p@email.com', '1992-03-10', 'M', NULL, TRUE),
('Sneha Reddy', 'AB+', 'No health issues', '23 Rose Garden', '8765432104', 'sneha.r@email.com', '1995-12-05', 'F', '2025-09-20', TRUE),
('Vikram Singh', 'O-', 'Healthy, Universal donor', '67 Palm Street', '8765432105', 'vikram.s@email.com', '1987-07-18', 'M', '2025-10-10', TRUE),
('Anita Desai', 'A-', 'Regular health checkups done', '89 Hill View', '8765432106', 'anita.d@email.com', '1991-11-30', 'F', '2025-12-01', TRUE),
('Rahul Mehta', 'B-', 'Good health condition', '34 River Side', '8765432107', 'rahul.m@email.com', '1993-04-25', 'M', NULL, TRUE),
('Kavita Joshi', 'AB-', 'Healthy donor', '56 Valley Road', '8765432108', 'kavita.j@email.com', '1989-09-14', 'F', '2025-11-20', TRUE),
('Suresh Gupta', 'O+', 'No medical complications', '91 Station Road', '8765432109', 'suresh.g@email.com', '1994-02-08', 'M', '2025-10-25', TRUE),
('Deepa Nair', 'A+', 'Healthy and fit', '73 Beach Road', '8765432110', 'deepa.n@email.com', '1996-06-12', 'F', NULL, TRUE);

-- Insert Patients
INSERT INTO Patient (patient_name, blood_group, disease, contact_number, address, date_of_birth, gender, admission_date, hospital_name) VALUES
('Mohan Verma', 'O+', 'Anemia', '7654321001', '15 Hospital Road', '1985-03-20', 'M', '2026-02-05', 'City General Hospital'),
('Sunita Kapoor', 'A+', 'Thalassemia', '7654321002', '28 Medical Lane', '1992-07-15', 'F', '2026-02-08', 'Apollo Hospital'),
('Ravi Yadav', 'B+', 'Surgery - Blood Loss', '7654321003', '42 Emergency Street', '1980-11-05', 'M', '2026-02-10', 'Central Hospital'),
('Meena Iyer', 'AB+', 'Cancer Treatment', '7654321004', '36 Care Avenue', '1975-09-30', 'F', '2026-01-20', 'Max Hospital'),
('Arun Kumar', 'O-', 'Accident - Critical', '7654321005', '19 Trauma Center', '1998-01-12', 'M', '2026-02-11', 'Emergency Care Hospital'),
('Lakshmi Rao', 'A-', 'Dengue Fever', '7654321006', '52 Health Street', '1990-05-25', 'F', '2026-02-09', 'City Medical Center'),
('Harish Pandey', 'B-', 'Surgery Required', '7654321007', '64 Operation Lane', '1983-12-18', 'M', '2026-02-07', 'Fortis Hospital'),
('Geeta Menon', 'AB-', 'Blood Disorder', '7654321008', '77 Clinic Road', '1988-08-08', 'F', '2026-02-06', 'AIIMS Hospital');

-- Insert Blood Inventory (Initial Stock)
INSERT INTO Blood_Inventory (blood_bank_id, blood_group, quantity_ml) VALUES
-- City Blood Bank
(1, 'A+', 5000), (1, 'A-', 2000), (1, 'B+', 4500), (1, 'B-', 1500),
(1, 'AB+', 2500), (1, 'AB-', 1000), (1, 'O+', 8000), (1, 'O-', 3000),
-- Central Blood Center
(2, 'A+', 6000), (2, 'A-', 2500), (2, 'B+', 5000), (2, 'B-', 2000),
(2, 'AB+', 3000), (2, 'AB-', 1200), (2, 'O+', 9000), (2, 'O-', 3500),
-- Red Cross Blood Bank
(3, 'A+', 4000), (3, 'A-', 1800), (3, 'B+', 3500), (3, 'B-', 1200),
(3, 'AB+', 2000), (3, 'AB-', 800), (3, 'O+', 7000), (3, 'O-', 2500),
-- Apollo Blood Bank
(4, 'A+', 5500), (4, 'A-', 2200), (4, 'B+', 4800), (4, 'B-', 1800),
(4, 'AB+', 2800), (4, 'AB-', 1100), (4, 'O+', 8500), (4, 'O-', 3200),
-- Lifeline Blood Bank
(5, 'A+', 4500), (5, 'A-', 1900), (5, 'B+', 4000), (5, 'B-', 1400),
(5, 'AB+', 2300), (5, 'AB-', 900), (5, 'O+', 7500), (5, 'O-', 2800);

-- Insert Donations
INSERT INTO Donation (donor_id, blood_bank_id, donation_date, blood_group, quantity_ml, donation_type, status, remarks) VALUES
(1, 1, '2025-10-01', 'O+', 450, 'Whole Blood', 'Approved', 'Healthy donor'),
(2, 1, '2025-11-15', 'A+', 450, 'Whole Blood', 'Approved', 'Regular donor'),
(3, 2, '2026-01-10', 'B+', 450, 'Whole Blood', 'Tested', 'Awaiting final approval'),
(4, 2, '2025-09-20', 'AB+', 450, 'Whole Blood', 'Approved', 'No issues'),
(5, 3, '2025-10-10', 'O-', 450, 'Whole Blood', 'Approved', 'Universal donor'),
(6, 3, '2025-12-01', 'A-', 450, 'Whole Blood', 'Approved', 'Good condition'),
(7, 4, '2026-01-20', 'B-', 450, 'Whole Blood', 'Pending', 'Under testing'),
(8, 4, '2025-11-20', 'AB-', 450, 'Whole Blood', 'Approved', 'Rare blood group'),
(9, 5, '2025-10-25', 'O+', 450, 'Whole Blood', 'Approved', 'Healthy donor'),
(1, 5, '2026-01-15', 'O+', 450, 'Platelets', 'Approved', 'Platelet donation'),
(2, 2, '2026-02-01', 'A+', 450, 'Plasma', 'Tested', 'Plasma donation'),
(5, 1, '2026-01-25', 'O-', 450, 'Whole Blood', 'Approved', 'Emergency donation');

-- Insert Blood Requests
INSERT INTO Blood_Request (
	patient_id,
	blood_bank_id,
	blood_group,
	quantity_ml,
	request_date,
	required_by_date,
	urgency,
	status,
	remarks,
	fulfilled_date
) VALUES
(1, 1, 'O+', 1000, '2026-02-05', '2026-02-12', 'Medium', 'Pending', 'Regular treatment', NULL),
(2, 4, 'A+', 1500, '2026-02-08', '2026-02-15', 'High', 'Approved', 'Thalassemia patient needs regular transfusion', NULL),
(3, 2, 'B+', 2000, '2026-02-10', '2026-02-11', 'High', 'Fulfilled', 'Post surgery requirement', '2026-02-10'),
(4, 4, 'AB+', 1200, '2026-01-20', '2026-02-20', 'Medium', 'Fulfilled', 'Cancer treatment', '2026-01-25'),
(5, 1, 'O-', 2500, '2026-02-11', '2026-02-11', 'Critical', 'Pending', 'Accident victim - Emergency', NULL),
(6, 3, 'A-', 1000, '2026-02-09', '2026-02-14', 'High', 'Approved', 'Dengue patient with low platelet count', NULL),
(7, 4, 'B-', 1800, '2026-02-07', '2026-02-12', 'High', 'Pending', 'Pre-surgery requirement', NULL),
(8, 2, 'AB-', 1500, '2026-02-06', '2026-02-16', 'Medium', 'Approved', 'Blood disorder treatment', NULL);

-- ========================================
-- Display Summary Information
-- ========================================

-- Summary: Blood Banks
SELECT 'BLOOD BANKS SUMMARY' AS Info;
SELECT blood_bank_id, bank_name, city, contact_number FROM Blood_Bank;

-- Summary: Donors by Blood Group
SELECT 'DONORS BY BLOOD GROUP' AS Info;
SELECT blood_group, COUNT(*) AS donor_count FROM Donor GROUP BY blood_group ORDER BY blood_group;

-- Summary: Patients by Blood Group
SELECT 'PATIENTS BY BLOOD GROUP' AS Info;
SELECT blood_group, COUNT(*) AS patient_count FROM Patient GROUP BY blood_group ORDER BY blood_group;

-- Summary: Total Blood Inventory
SELECT 'TOTAL BLOOD STOCK' AS Info;
SELECT blood_group, SUM(quantity_ml) AS total_ml, SUM(quantity_ml)/1000 AS total_liters
FROM Blood_Inventory
GROUP BY blood_group
ORDER BY blood_group;

-- Summary: Donations by Status
SELECT 'DONATIONS BY STATUS' AS Info;
SELECT status, COUNT(*) AS donation_count, SUM(quantity_ml) AS total_ml
FROM Donation
GROUP BY status;

-- Summary: Blood Requests by Status
SELECT 'BLOOD REQUESTS BY STATUS' AS Info;
SELECT status, COUNT(*) AS request_count, SUM(quantity_ml) AS total_ml_requested
FROM Blood_Request
GROUP BY status;
