# Database Normalization Documentation
## Blood Bank Management System

---

## Table of Contents
1. [Introduction to Normalization](#introduction)
2. [First Normal Form (1NF)](#first-normal-form)
3. [Second Normal Form (2NF)](#second-normal-form)
4. [Third Normal Form (3NF)](#third-normal-form)
5. [Benefits of Normalization](#benefits)
6. [Tables and Their Normal Forms](#tables-analysis)

---

## Introduction to Normalization {#introduction}

Database normalization is the process of organizing data to:
- Minimize redundancy
- Eliminate insertion, update, and deletion anomalies
- Ensure data dependencies make sense

The Blood Bank Management System is normalized to **Third Normal Form (3NF)**, ensuring optimal data organization without redundancy.

---

## First Normal Form (1NF) {#first-normal-form}

### Definition
A table is in 1NF if:
1. All columns contain atomic (indivisible) values
2. Each column contains values of a single type
3. Each column has a unique name
4. The order of rows doesn't matter
5. There are no repeating groups or arrays

### Implementation in Our System

#### ✅ Blood_Bank Table
```sql
CREATE TABLE Blood_Bank (
    blood_bank_id INT PRIMARY KEY,
    bank_name VARCHAR(100),      -- Atomic value
    address VARCHAR(255),         -- Single complete address
    contact_number VARCHAR(15),   -- Single phone number
    email VARCHAR(100),           -- Single email
    city VARCHAR(50),             -- Atomic value
    state VARCHAR(50)             -- Atomic value
);
```

**Why it's in 1NF:**
- Each field contains a single, atomic value
- No repeating groups (e.g., contact_number1, contact_number2)
- No arrays or lists in any column
- Each row is uniquely identified by blood_bank_id

#### ✅ Donor Table
```sql
CREATE TABLE Donor (
    donor_id INT PRIMARY KEY,
    donor_name VARCHAR(100),      -- Single name (atomic)
    blood_group ENUM(...),        -- Single blood type
    medical_report TEXT,          -- Single report
    address VARCHAR(255),         -- Complete address
    contact_number VARCHAR(15),   -- Single contact
    date_of_birth DATE,          -- Single date
    gender ENUM(...)             -- Single value
);
```

**Why it's in 1NF:**
- All attributes are atomic
- No multi-valued attributes
- Each donor has one primary contact, not a list

#### ❌ What Would Violate 1NF:

```sql
-- BAD: Multiple phone numbers in one field
CREATE TABLE Donor_Bad (
    donor_id INT,
    donor_name VARCHAR(100),
    phone_numbers VARCHAR(255)  -- "123-456, 789-012, 345-678"
);

-- BAD: Repeating groups
CREATE TABLE Donor_Bad2 (
    donor_id INT,
    donor_name VARCHAR(100),
    phone1 VARCHAR(15),
    phone2 VARCHAR(15),
    phone3 VARCHAR(15)
);

-- BAD: Array/List
CREATE TABLE Blood_Bank_Bad (
    bank_id INT,
    bank_name VARCHAR(100),
    donor_names TEXT  -- "John, Jane, Bob, Alice"
);
```

---

## Second Normal Form (2NF) {#second-normal-form}

### Definition
A table is in 2NF if:
1. It is in 1NF
2. All non-key attributes are fully functionally dependent on the primary key
3. No partial dependencies exist (applies to composite keys)

### Implementation in Our System

#### ✅ Donation Table (Composite Key Example)
```sql
CREATE TABLE Donation (
    donation_id INT PRIMARY KEY,  -- Surrogate key
    donor_id INT,
    blood_bank_id INT,
    donation_date DATE,
    blood_group ENUM(...),
    quantity_ml INT,
    donation_type ENUM(...),
    status ENUM(...),
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id)
);
```

**Why it's in 2NF:**
- Uses a surrogate key (donation_id) as primary key
- All attributes depend on the complete primary key (donation_id)
- No partial dependencies exist
- Donor information is stored in Donor table (not repeated here)
- Blood Bank information is stored in Blood_Bank table (not repeated here)

#### ✅ Blood_Request Table
```sql
CREATE TABLE Blood_Request (
    request_id INT PRIMARY KEY,   -- Surrogate key
    patient_id INT,
    blood_bank_id INT,
    blood_group ENUM(...),
    quantity_ml INT,
    request_date DATE,
    urgency ENUM(...),
    status ENUM(...),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id)
);
```

**Why it's in 2NF:**
- All non-key attributes fully depend on request_id
- Patient details are in Patient table (referenced by FK)
- Blood Bank details are in Blood_Bank table (referenced by FK)

#### ❌ What Would Violate 2NF:

```sql
-- BAD: Partial dependency
CREATE TABLE Donation_Bad (
    donor_id INT,
    blood_bank_id INT,
    donation_date DATE,
    donor_name VARCHAR(100),      -- Depends only on donor_id
    donor_address VARCHAR(255),   -- Depends only on donor_id
    bank_name VARCHAR(100),       -- Depends only on blood_bank_id
    bank_address VARCHAR(255),    -- Depends only on blood_bank_id
    quantity_ml INT,
    PRIMARY KEY (donor_id, blood_bank_id, donation_date)
);
-- Problem: donor_name depends only on donor_id (partial dependency)
-- Problem: bank_name depends only on blood_bank_id (partial dependency)
```

---

## Third Normal Form (3NF) {#third-normal-form}

### Definition
A table is in 3NF if:
1. It is in 2NF
2. No transitive dependencies exist
3. All non-key attributes depend directly on the primary key, not on other non-key attributes

### Implementation in Our System

#### ✅ Patient Table
```sql
CREATE TABLE Patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    blood_group ENUM(...),
    disease VARCHAR(200),
    contact_number VARCHAR(15),
    address VARCHAR(255),
    hospital_name VARCHAR(100),  -- Just the name, not full details
    admission_date DATE
);
```

**Why it's in 3NF:**
- All attributes depend directly on patient_id
- No transitive dependencies
- hospital_name is just a reference (if we needed hospital details, we'd create a separate Hospital table)

#### ✅ Blood_Inventory Table
```sql
CREATE TABLE Blood_Inventory (
    inventory_id INT PRIMARY KEY,
    blood_bank_id INT,
    blood_group ENUM(...),
    quantity_ml INT,
    last_updated TIMESTAMP,
    FOREIGN KEY (blood_bank_id) REFERENCES Blood_Bank(blood_bank_id),
    UNIQUE KEY (blood_bank_id, blood_group)
);
```

**Why it's in 3NF:**
- Inventory is separate from Blood_Bank (no redundancy)
- quantity_ml depends on the combination of blood_bank_id and blood_group
- No transitive dependencies

#### ✅ Separate Tables for Entities

Instead of storing donor information with donations, we have:

**Donor Table** (stores donor info)
```sql
CREATE TABLE Donor (
    donor_id INT PRIMARY KEY,
    donor_name VARCHAR(100),
    blood_group ENUM(...),
    address VARCHAR(255),
    contact_number VARCHAR(15)
);
```

**Donation Table** (references donor)
```sql
CREATE TABLE Donation (
    donation_id INT PRIMARY KEY,
    donor_id INT,  -- Foreign key reference
    blood_bank_id INT,
    donation_date DATE,
    quantity_ml INT,
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id)
);
```

#### ❌ What Would Violate 3NF:

```sql
-- BAD: Transitive dependency
CREATE TABLE Patient_Bad (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    hospital_name VARCHAR(100),
    hospital_address VARCHAR(255),  -- Depends on hospital_name
    hospital_phone VARCHAR(15),     -- Depends on hospital_name
    disease VARCHAR(200)
);
-- Problem: hospital_address depends on hospital_name, not patient_id
-- Solution: Create separate Hospital table
```

```sql
-- BAD: Redundant calculated data
CREATE TABLE Donation_Bad (
    donation_id INT PRIMARY KEY,
    donor_id INT,
    blood_bank_id INT,
    donor_name VARCHAR(100),        -- Stored redundantly
    donor_blood_group VARCHAR(3),   -- Stored redundantly
    bank_name VARCHAR(100),         -- Stored redundantly
    donation_date DATE,
    quantity_ml INT
);
-- Problem: Donor and Bank information duplicated
```

---

## Benefits of Normalization {#benefits}

### 1. **Data Integrity**
```sql
-- If we need to update a donor's address:
UPDATE Donor 
SET address = 'New Address' 
WHERE donor_id = 1;

-- Without normalization, we'd need to update multiple donation records
-- UPDATE Donation SET donor_address = 'New Address' WHERE donor_id = 1;
```

### 2. **No Update Anomalies**
- Changing donor information in one place updates it everywhere
- No risk of inconsistent data across tables

### 3. **No Insertion Anomalies**
- Can add a donor without requiring a donation
- Can add a blood bank without requiring inventory

### 4. **No Deletion Anomalies**
- Deleting a donation doesn't delete donor information
- CASCADE rules handle relationships properly

### 5. **Storage Efficiency**
- Donor information stored once, referenced many times
- Blood bank information stored once, referenced many times

---

## Tables and Their Normal Forms {#tables-analysis}

### Summary Table

| Table | 1NF | 2NF | 3NF | Explanation |
|-------|-----|-----|-----|-------------|
| **Blood_Bank** | ✅ | ✅ | ✅ | All atomic values, no partial/transitive dependencies |
| **Donor** | ✅ | ✅ | ✅ | All atomic values, no partial/transitive dependencies |
| **Patient** | ✅ | ✅ | ✅ | All atomic values, no partial/transitive dependencies |
| **Donation** | ✅ | ✅ | ✅ | Uses surrogate key, references Donor and Blood_Bank |
| **Blood_Inventory** | ✅ | ✅ | ✅ | Separate tracking, no redundancy with Blood_Bank |
| **Blood_Request** | ✅ | ✅ | ✅ | Uses surrogate key, references Patient and Blood_Bank |

---

## Detailed Analysis by Table

### 1. Blood_Bank Table
- **Primary Key:** blood_bank_id
- **1NF:** ✅ All fields are atomic
- **2NF:** ✅ All non-key attributes fully depend on blood_bank_id
- **3NF:** ✅ No transitive dependencies

### 2. Donor Table
- **Primary Key:** donor_id
- **1NF:** ✅ No repeating groups or multi-valued attributes
- **2NF:** ✅ All attributes fully depend on donor_id
- **3NF:** ✅ No transitive dependencies (medical_report depends on donor_id directly)

### 3. Patient Table
- **Primary Key:** patient_id
- **1NF:** ✅ All atomic values
- **2NF:** ✅ All attributes depend on patient_id
- **3NF:** ✅ hospital_name is just a reference, not full details

### 4. Donation Table (Junction Table)
- **Primary Key:** donation_id
- **Foreign Keys:** donor_id, blood_bank_id
- **1NF:** ✅ No repeating groups
- **2NF:** ✅ Uses surrogate key, no partial dependencies
- **3NF:** ✅ Donor and bank details in separate tables

**Relationships:**
- Many-to-Many: Donor ↔ Blood_Bank
- Resolved through Donation table

### 5. Blood_Inventory Table
- **Primary Key:** inventory_id
- **Unique Key:** (blood_bank_id, blood_group)
- **1NF:** ✅ Atomic values only
- **2NF:** ✅ All attributes depend on inventory_id
- **3NF:** ✅ Separate from Blood_Bank table (no redundancy)

**Why separate from Blood_Bank:**
```sql
-- Instead of storing blood quantities in Blood_Bank:
-- blood_bank_id | bank_name | quantity_A+ | quantity_B+ | ...
-- We have a flexible Inventory table:
-- inventory_id | blood_bank_id | blood_group | quantity_ml
```

### 6. Blood_Request Table (Junction Table)
- **Primary Key:** request_id
- **Foreign Keys:** patient_id, blood_bank_id
- **1NF:** ✅ All atomic values
- **2NF:** ✅ Uses surrogate key
- **3NF:** ✅ Patient and bank details in separate tables

**Relationships:**
- Many-to-Many: Patient ↔ Blood_Bank
- Resolved through Blood_Request table

---

## Verification Examples

### Example 1: Adding a New Donor
```sql
-- Step 1: Add donor (no donation required)
INSERT INTO Donor (donor_name, blood_group, address, contact_number)
VALUES ('New Donor', 'O+', '123 Street', '1234567890');

-- Step 2: Later, add donation (references donor)
INSERT INTO Donation (donor_id, blood_bank_id, donation_date, blood_group, quantity_ml)
VALUES (11, 1, '2026-02-11', 'O+', 450);
```
✅ **No insertion anomaly** - Can add donor without donation

### Example 2: Updating Donor Information
```sql
-- Update donor address
UPDATE Donor 
SET address = 'New Address'
WHERE donor_id = 5;
```
✅ **No update anomaly** - Single update point, no inconsistency

### Example 3: Deleting a Donation
```sql
-- Delete a donation record
DELETE FROM Donation WHERE donation_id = 10;
```
✅ **No deletion anomaly** - Donor information remains intact

---

## Conclusion

The Blood Bank Management System is fully normalized to 3NF:

1. **1NF** - All tables have atomic values, no repeating groups
2. **2NF** - No partial dependencies, all tables use proper keys
3. **3NF** - No transitive dependencies, all related entities in separate tables

This design ensures:
- **Data integrity**
- **No redundancy**
- **Easy maintenance**
- **Scalability**
- **Efficient queries**

The normalization process has eliminated all forms of anomalies while maintaining referential integrity through foreign key constraints.
