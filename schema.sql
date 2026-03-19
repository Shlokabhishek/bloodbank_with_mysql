-- ========================================
-- BLOOD BANK MANAGEMENT SYSTEM - DATABASE SCHEMA
-- ========================================
-- This schema is normalized to 3NF to eliminate redundancy
-- and maintain data integrity

-- Drop existing tables if they exist
DROP TABLE IF EXISTS Blood_Request;
DROP TABLE IF EXISTS Donation;
DROP TABLE IF EXISTS Blood_Inventory;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS Blood_Bank;

-- ========================================
-- TABLE: Blood_Bank
-- Stores information about blood banks
-- ========================================
CREATE TABLE Blood_Bank (
    blood_bank_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact_number VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_contact CHECK (contact_number REGEXP '^[0-9]{10,15}$')
);

-- ========================================
-- TABLE: Donor
-- Stores information about blood donors
-- ========================================
CREATE TABLE Donor (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_name VARCHAR(100) NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    medical_report TEXT,
    address VARCHAR(255) NOT NULL,
    contact_number VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    last_donation_date DATE,
    is_eligible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_donor_contact CHECK (contact_number REGEXP '^[0-9]{10,15}$')
);

-- ========================================
-- TABLE: Patient
-- Stores information about patients who need blood
-- ========================================
CREATE TABLE Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    disease VARCHAR(200) NOT NULL,
    contact_number VARCHAR(15),
    address VARCHAR(255),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    admission_date DATE,
    hospital_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_patient_contact CHECK (contact_number REGEXP '^[0-9]{10,15}$')
);

-- ========================================
-- TABLE: Donation
-- Tracks donations made by donors to blood banks
-- This is a junction table that creates many-to-many relationship
-- between Donor and Blood_Bank
-- ========================================
CREATE TABLE Donation (
    donation_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    blood_bank_id INT NOT NULL,
    donation_date DATE NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    quantity_ml INT NOT NULL,
    donation_type ENUM('Whole Blood', 'Plasma', 'Platelets', 'Red Cells') DEFAULT 'Whole Blood',
    status ENUM('Pending', 'Tested', 'Approved', 'Rejected') DEFAULT 'Pending',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id) ON DELETE CASCADE,
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id) ON DELETE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity_ml > 0 AND quantity_ml <= 500)
);

-- ========================================
-- TABLE: Blood_Inventory
-- Tracks available blood units in each blood bank by blood group
-- ========================================
CREATE TABLE Blood_Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    blood_bank_id INT NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    quantity_ml INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id) ON DELETE CASCADE,
    UNIQUE KEY unique_bank_blood_group (blood_bank_id, blood_group),
    CONSTRAINT chk_inventory_quantity CHECK (quantity_ml >= 0)
);

-- ========================================
-- TABLE: Blood_Request
-- Tracks blood requests made by patients
-- Creates many-to-many relationship between Patient and Blood_Bank
-- ========================================
CREATE TABLE Blood_Request (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    blood_bank_id INT NOT NULL,
    blood_group ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    quantity_ml INT NOT NULL,
    request_date DATE NOT NULL,
    required_by_date DATE,
    urgency ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    status ENUM('Pending', 'Approved', 'Fulfilled', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    remarks TEXT,
    fulfilled_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id) ON DELETE CASCADE,
    CONSTRAINT chk_request_quantity CHECK (quantity_ml > 0)
);

-- ========================================
-- INDEXES for Performance Optimization
-- ========================================
CREATE INDEX idx_donor_blood_group ON Donor(blood_group);
CREATE INDEX idx_patient_blood_group ON Patient(blood_group);
CREATE INDEX idx_donation_date ON Donation(donation_date);
CREATE INDEX idx_donation_status ON Donation(status);
CREATE INDEX idx_request_status ON Blood_Request(status);
CREATE INDEX idx_request_date ON Blood_Request(request_date);
CREATE INDEX idx_inventory_blood_group ON Blood_Inventory(blood_group);

-- ========================================
-- VIEWS for Common Queries
-- ========================================

-- View: Available Blood Stock Summary
CREATE VIEW vw_blood_stock_summary AS
SELECT 
    bb.bank_name,
    bb.city,
    bi.blood_group,
    bi.quantity_ml,
    bi.last_updated
FROM Blood_Inventory bi
JOIN Blood_Bank bb ON bi.blood_bank_id = bb.blood_bank_id
ORDER BY bb.bank_name, bi.blood_group;

-- View: Eligible Donors
CREATE VIEW vw_eligible_donors AS
SELECT 
    donor_id,
    donor_name,
    blood_group,
    contact_number,
    last_donation_date,
    DATEDIFF(CURDATE(), last_donation_date) AS days_since_last_donation
FROM Donor
WHERE is_eligible = TRUE
  AND (last_donation_date IS NULL OR DATEDIFF(CURDATE(), last_donation_date) >= 90);

-- View: Pending Blood Requests
CREATE VIEW vw_pending_requests AS
SELECT 
    br.request_id,
    p.patient_name,
    p.disease,
    br.blood_group,
    br.quantity_ml,
    br.urgency,
    br.request_date,
    br.required_by_date,
    bb.bank_name,
    bb.contact_number AS bank_contact
FROM Blood_Request br
JOIN Patient p ON br.patient_id = p.patient_id
JOIN Blood_Bank bb ON br.blood_bank_id = bb.blood_bank_id
WHERE br.status = 'Pending'
ORDER BY 
    FIELD(br.urgency, 'Critical', 'High', 'Medium', 'Low'),
    br.request_date;

-- View: Donation History
CREATE VIEW vw_donation_history AS
SELECT 
    d.donation_id,
    don.donor_name,
    don.contact_number AS donor_contact,
    d.blood_group,
    d.quantity_ml,
    d.donation_date,
    d.donation_type,
    d.status,
    bb.bank_name
FROM Donation d
JOIN Donor don ON d.donor_id = don.donor_id
JOIN Blood_Bank bb ON d.blood_bank_id = bb.blood_bank_id
ORDER BY d.donation_date DESC;

-- ========================================
-- TRIGGERS for Automatic Updates
-- ========================================

-- Trigger: Update Blood Inventory after approved donation
DELIMITER //
CREATE TRIGGER trg_update_inventory_after_donation
AFTER UPDATE ON Donation
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved' AND OLD.status != 'Approved' THEN
        -- Check if inventory record exists
        INSERT INTO Blood_Inventory (blood_bank_id, blood_group, quantity_ml)
        VALUES (NEW.blood_bank_id, NEW.blood_group, NEW.quantity_ml)
        ON DUPLICATE KEY UPDATE 
            quantity_ml = quantity_ml + NEW.quantity_ml;
    END IF;
END;//

-- Trigger: Update inventory when blood request is fulfilled
CREATE TRIGGER trg_update_inventory_after_request
AFTER UPDATE ON Blood_Request
FOR EACH ROW
BEGIN
    IF NEW.status = 'Fulfilled' AND OLD.status != 'Fulfilled' THEN
        UPDATE Blood_Inventory
        SET quantity_ml = quantity_ml - NEW.quantity_ml
        WHERE blood_bank_id = NEW.blood_bank_id 
          AND blood_group = NEW.blood_group;
    END IF;
END;//

-- Trigger: Update donor's last donation date
CREATE TRIGGER trg_update_donor_last_donation
AFTER INSERT ON Donation
FOR EACH ROW
BEGIN
    UPDATE Donor
    SET last_donation_date = NEW.donation_date
    WHERE donor_id = NEW.donor_id;
END;//

DELIMITER ;

-- ========================================
-- STORED PROCEDURES
-- ========================================

-- Procedure: Check Blood Availability
DELIMITER //
CREATE PROCEDURE sp_check_blood_availability(
    IN p_blood_bank_id INT,
    IN p_blood_group VARCHAR(3),
    IN p_required_quantity INT,
    OUT p_available_quantity INT,
    OUT p_is_available BOOLEAN
)
BEGIN
    SELECT quantity_ml INTO p_available_quantity
    FROM Blood_Inventory
    WHERE blood_bank_id = p_blood_bank_id 
      AND blood_group = p_blood_group;
    
    IF p_available_quantity IS NULL THEN
        SET p_available_quantity = 0;
    END IF;
    
    SET p_is_available = (p_available_quantity >= p_required_quantity);
END;//

-- Procedure: Get Compatible Donors
CREATE PROCEDURE sp_get_compatible_donors(
    IN p_blood_group VARCHAR(3)
)
BEGIN
    -- Blood compatibility logic
    SELECT 
        donor_id,
        donor_name,
        blood_group,
        contact_number,
        address
    FROM Donor
    WHERE is_eligible = TRUE
      AND (last_donation_date IS NULL OR DATEDIFF(CURDATE(), last_donation_date) >= 90)
      AND (
          -- Exact match
          blood_group = p_blood_group
          -- Universal donor
          OR blood_group = 'O-'
          -- Type O can receive from O
          OR (p_blood_group IN ('O+', 'O-') AND blood_group IN ('O+', 'O-'))
          -- Type A can receive from A and O
          OR (p_blood_group IN ('A+', 'A-') AND blood_group IN ('A+', 'A-', 'O+', 'O-'))
          -- Type B can receive from B and O
          OR (p_blood_group IN ('B+', 'B-') AND blood_group IN ('B+', 'B-', 'O+', 'O-'))
          -- Type AB can receive from all
          OR (p_blood_group IN ('AB+', 'AB-'))
      );
END;//

DELIMITER ;
