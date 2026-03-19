-- ========================================
-- USEFUL QUERIES - Blood Bank Management System
-- ========================================

-- ========================================
-- SECTION 1: BASIC QUERIES
-- ========================================

-- 1.1 View all donors
SELECT * FROM Donor ORDER BY donor_name;

-- 1.2 View all patients
SELECT * FROM Patient ORDER BY patient_name;

-- 1.3 View all blood banks
SELECT * FROM Blood_Bank ORDER BY bank_name;

-- 1.4 View all donations
SELECT * FROM Donation ORDER BY donation_date DESC;

-- 1.5 View all blood requests
SELECT * FROM Blood_Request ORDER BY request_date DESC;

-- ========================================
-- SECTION 2: FILTERING QUERIES
-- ========================================

-- 2.1 Find donors by blood group
SELECT donor_id, donor_name, blood_group, contact_number, last_donation_date
FROM Donor
WHERE blood_group = 'O+'
AND is_eligible = TRUE;

-- 2.2 Find patients needing specific blood group
SELECT patient_id, patient_name, disease, hospital_name
FROM Patient
WHERE blood_group = 'A+';cd "c:\Users\Shlok Abhishek\OneDrive\Desktop\.vscode\bllod dbms project\project-folder"
npm install

-- 2.3 Get pending blood requests
SELECT * FROM Blood_Request
WHERE status = 'Pending'
ORDER BY 
    FIELD(urgency, 'Critical', 'High', 'Medium', 'Low'),
    request_date;

-- 2.4 Get eligible donors (can donate now)
SELECT donor_id, donor_name, blood_group, contact_number
FROM Donor
WHERE is_eligible = TRUE
  AND (last_donation_date IS NULL OR DATEDIFF(CURDATE(), last_donation_date) >= 90);

-- 2.5 Get critical blood requests
SELECT br.request_id, p.patient_name, br.blood_group, br.quantity_ml, br.request_date
FROM Blood_Request br
JOIN Patient p ON br.patient_id = p.patient_id
WHERE br.urgency = 'Critical' AND br.status = 'Pending';

-- ========================================
-- SECTION 3: JOIN QUERIES
-- ========================================

-- 3.1 Get complete donation information
SELECT 
    d.donation_id,
    don.donor_name,
    don.blood_group,
    bb.bank_name,
    d.donation_date,
    d.quantity_ml,
    d.donation_type,
    d.status
FROM Donation d
JOIN Donor don ON d.donor_id = don.donor_id
JOIN Blood_Bank bb ON d.blood_bank_id = bb.blood_bank_id
ORDER BY d.donation_date DESC;

-- 3.2 Get complete blood request information
SELECT 
    br.request_id,
    p.patient_name,
    p.disease,
    br.blood_group,
    br.quantity_ml,
    bb.bank_name,
    br.urgency,
    br.status,
    br.request_date
FROM Blood_Request br
JOIN Patient p ON br.patient_id = p.patient_id
JOIN Blood_Bank bb ON br.blood_bank_id = bb.blood_bank_id
ORDER BY br.request_date DESC;

-- 3.3 Get donor donation history
SELECT 
    don.donor_name,
    don.blood_group,
    d.donation_date,
    bb.bank_name,
    d.quantity_ml,
    d.status
FROM Donor don
JOIN Donation d ON don.donor_id = d.donor_id
JOIN Blood_Bank bb ON d.blood_bank_id = bb.blood_bank_id
WHERE don.donor_id = 1
ORDER BY d.donation_date DESC;

-- ========================================
-- SECTION 4: AGGREGATE QUERIES
-- ========================================

-- 4.1 Count donors by blood group
SELECT blood_group, COUNT(*) as donor_count
FROM Donor
GROUP BY blood_group
ORDER BY blood_group;

-- 4.2 Total blood collected by blood bank
SELECT 
    bb.bank_name,
    COUNT(d.donation_id) as total_donations,
    SUM(d.quantity_ml) as total_ml_collected,
    ROUND(SUM(d.quantity_ml) / 1000, 2) as total_liters
FROM Blood_Bank bb
LEFT JOIN Donation d ON bb.blood_bank_id = d.blood_bank_id
WHERE d.status = 'Approved'
GROUP BY bb.blood_bank_id
ORDER BY total_ml_collected DESC;

-- 4.3 Blood requests by urgency
SELECT 
    urgency,
    COUNT(*) as request_count,
    SUM(quantity_ml) as total_ml_requested
FROM Blood_Request
WHERE status != 'Cancelled'
GROUP BY urgency
ORDER BY FIELD(urgency, 'Critical', 'High', 'Medium', 'Low');

-- 4.4 Average donation quantity by blood group
SELECT 
    blood_group,
    COUNT(*) as donation_count,
    AVG(quantity_ml) as avg_quantity,
    MIN(quantity_ml) as min_quantity,
    MAX(quantity_ml) as max_quantity
FROM Donation
WHERE status = 'Approved'
GROUP BY blood_group;

-- 4.5 Monthly donation statistics
SELECT 
    DATE_FORMAT(donation_date, '%Y-%m') as month,
    COUNT(*) as donations,
    SUM(quantity_ml) as total_ml
FROM Donation
WHERE status = 'Approved'
GROUP BY DATE_FORMAT(donation_date, '%Y-%m')
ORDER BY month DESC;

-- ========================================
-- SECTION 5: INVENTORY QUERIES
-- ========================================

-- 5.1 Current blood stock summary
SELECT 
    bb.bank_name,
    bb.city,
    bi.blood_group,
    bi.quantity_ml,
    ROUND(bi.quantity_ml / 1000, 2) as quantity_liters
FROM Blood_Inventory bi
JOIN Blood_Bank bb ON bi.blood_bank_id = bb.blood_bank_id
ORDER BY bb.bank_name, bi.blood_group;

-- 5.2 Low stock alert (less than 2 liters)
SELECT 
    bb.bank_name,
    bi.blood_group,
    bi.quantity_ml,
    'LOW STOCK' as alert
FROM Blood_Inventory bi
JOIN Blood_Bank bb ON bi.blood_bank_id = bb.blood_bank_id
WHERE bi.quantity_ml < 2000
ORDER BY bi.quantity_ml;

-- 5.3 Total blood available by blood group
SELECT 
    blood_group,
    SUM(quantity_ml) as total_ml,
    ROUND(SUM(quantity_ml) / 1000, 2) as total_liters,
    COUNT(DISTINCT blood_bank_id) as banks_with_stock
FROM Blood_Inventory
WHERE quantity_ml > 0
GROUP BY blood_group
ORDER BY blood_group;

-- 5.4 Blood banks with specific blood type in stock
SELECT 
    bb.bank_name,
    bb.address,
    bb.contact_number,
    bi.quantity_ml
FROM Blood_Bank bb
JOIN Blood_Inventory bi ON bb.blood_bank_id = bi.blood_bank_id
WHERE bi.blood_group = 'O-' AND bi.quantity_ml > 0
ORDER BY bi.quantity_ml DESC;

-- ========================================
-- SECTION 6: COMPLEX QUERIES
-- ========================================

-- 6.1 Match patients with available blood
SELECT 
    p.patient_name,
    p.blood_group,
    p.disease,
    bb.bank_name,
    bb.city,
    bi.quantity_ml as available_ml
FROM Patient p
JOIN Blood_Inventory bi ON p.blood_group = bi.blood_group
JOIN Blood_Bank bb ON bi.blood_bank_id = bb.blood_bank_id
WHERE bi.quantity_ml > 0
ORDER BY p.patient_name, bi.quantity_ml DESC;

-- 6.2 Active donors with recent donations
SELECT 
    don.donor_id,
    don.donor_name,
    don.blood_group,
    don.last_donation_date,
    COUNT(d.donation_id) as total_donations,
    SUM(d.quantity_ml) as total_donated
FROM Donor don
LEFT JOIN Donation d ON don.donor_id = d.donor_id AND d.status = 'Approved'
GROUP BY don.donor_id
HAVING total_donations > 0
ORDER BY total_donated DESC;

-- 6.3 Unfulfilled critical requests
SELECT 
    br.request_id,
    p.patient_name,
    p.disease,
    br.blood_group,
    br.quantity_ml,
    br.request_date,
    DATEDIFF(CURDATE(), br.request_date) as days_pending,
    bb.bank_name,
    bi.quantity_ml as available_stock
FROM Blood_Request br
JOIN Patient p ON br.patient_id = p.patient_id
JOIN Blood_Bank bb ON br.blood_bank_id = bb.blood_bank_id
LEFT JOIN Blood_Inventory bi ON bb.blood_bank_id = bi.blood_bank_id 
    AND br.blood_group = bi.blood_group
WHERE br.status = 'Pending' AND br.urgency = 'Critical'
ORDER BY br.request_date;

-- 6.4 Donation efficiency by blood bank
SELECT 
    bb.bank_name,
    COUNT(d.donation_id) as total_donations,
    SUM(CASE WHEN d.status = 'Approved' THEN 1 ELSE 0 END) as approved_donations,
    SUM(CASE WHEN d.status = 'Rejected' THEN 1 ELSE 0 END) as rejected_donations,
    ROUND(100 * SUM(CASE WHEN d.status = 'Approved' THEN 1 ELSE 0 END) / COUNT(d.donation_id), 2) as approval_rate
FROM Blood_Bank bb
LEFT JOIN Donation d ON bb.blood_bank_id = d.blood_bank_id
GROUP BY bb.blood_bank_id
HAVING total_donations > 0
ORDER BY approval_rate DESC;

-- 6.5 Blood type compatibility for patients
SELECT 
    p.patient_name,
    p.blood_group as patient_blood_group,
    don.donor_name,
    don.blood_group as donor_blood_group,
    don.contact_number,
    don.is_eligible
FROM Patient p
CROSS JOIN Donor don
WHERE 
    -- Blood compatibility logic
    (p.blood_group = don.blood_group)
    OR (don.blood_group = 'O-')
    OR (p.blood_group IN ('A+', 'A-') AND don.blood_group IN ('A+', 'A-', 'O+', 'O-'))
    OR (p.blood_group IN ('B+', 'B-') AND don.blood_group IN ('B+', 'B-', 'O+', 'O-'))
    OR (p.blood_group IN ('AB+', 'AB-') AND 1=1)
    AND don.is_eligible = TRUE
ORDER BY p.patient_name, don.blood_group;

-- ========================================
-- SECTION 7: UPDATE OPERATIONS
-- ========================================

-- 7.1 Approve a donation
UPDATE Donation
SET status = 'Approved'
WHERE donation_id = 1;

-- 7.2 Fulfill a blood request
UPDATE Blood_Request
SET status = 'Fulfilled',
    fulfilled_date = CURDATE()
WHERE request_id = 1;

-- 7.3 Update donor eligibility
UPDATE Donor
SET is_eligible = FALSE
WHERE donor_id = 1;

-- 7.4 Cancel a blood request
UPDATE Blood_Request
SET status = 'Cancelled',
    remarks = 'Request no longer needed'
WHERE request_id = 1;

-- ========================================
-- SECTION 8: REPORTING QUERIES
-- ========================================

-- 8.1 Daily donation report
SELECT 
    DATE(donation_date) as date,
    COUNT(*) as donations,
    SUM(quantity_ml) as total_ml,
    COUNT(DISTINCT donor_id) as unique_donors,
    COUNT(DISTINCT blood_bank_id) as blood_banks
FROM Donation
WHERE donation_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(donation_date)
ORDER BY date DESC;

-- 8.2 Blood bank performance report
SELECT 
    bb.bank_name,
    COUNT(DISTINCT d.donor_id) as unique_donors,
    COUNT(d.donation_id) as total_donations,
    SUM(d.quantity_ml) as total_collected,
    COUNT(br.request_id) as requests_received,
    SUM(CASE WHEN br.status = 'Fulfilled' THEN 1 ELSE 0 END) as requests_fulfilled
FROM Blood_Bank bb
LEFT JOIN Donation d ON bb.blood_bank_id = d.blood_bank_id
LEFT JOIN Blood_Request br ON bb.blood_bank_id = br.blood_bank_id
GROUP BY bb.blood_bank_id
ORDER BY total_collected DESC;

-- 8.3 Patient disease statistics
SELECT 
    disease,
    COUNT(*) as patient_count,
    blood_group,
    COUNT(*) as count_by_blood_group
FROM Patient
GROUP BY disease, blood_group
ORDER BY patient_count DESC;

-- ========================================
-- SECTION 9: USING VIEWS
-- ========================================

-- 9.1 View blood stock summary
SELECT * FROM vw_blood_stock_summary;

-- 9.2 View eligible donors
SELECT * FROM vw_eligible_donors
WHERE blood_group = 'O+';

-- 9.3 View pending requests
SELECT * FROM vw_pending_requests
WHERE urgency IN ('Critical', 'High');

-- 9.4 View donation history
SELECT * FROM vw_donation_history
WHERE donation_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- ========================================
-- SECTION 10: USING STORED PROCEDURES
-- ========================================

-- 10.1 Check blood availability
CALL sp_check_blood_availability(1, 'O+', 1000, @available, @is_available);
SELECT 
    @available AS available_quantity, 
    @is_available AS can_fulfill_request;

-- 10.2 Get compatible donors for a blood group
CALL sp_get_compatible_donors('A+');
