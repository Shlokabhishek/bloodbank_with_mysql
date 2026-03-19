// Tab Navigation
function showTab(tabName) {
    // Hide all tab contents
    const tabContents = document.querySelectorAll('.tab-content');
    tabContents.forEach(content => {
        content.classList.remove('active');
    });

    // Remove active class from all buttons
    const tabButtons = document.querySelectorAll('.tab-button');
    tabButtons.forEach(button => {
        button.classList.remove('active');
    });

    // Show selected tab
    document.getElementById(tabName).classList.add('active');
    event.target.classList.add('active');

    // Load blood banks if inventory tab is clicked
    if (tabName === 'inventory') {
        loadBloodBanks();
    }
    
    // Load dashboard if dashboard tab is clicked
    if (tabName === 'dashboard') {
        loadDashboard();
    }
}

// Show message to user
function showMessage(message, type = 'success') {
    const messageDiv = document.getElementById('message');
    messageDiv.textContent = message;
    messageDiv.className = `message ${type}`;
    messageDiv.style.display = 'block';

    setTimeout(() => {
        messageDiv.style.display = 'none';
    }, 5000);
}

// API Base URL for Python backend.
// You can override this from browser console: window.BLOOD_API_URL = 'http://127.0.0.1:5000/api'
const API_URL = window.BLOOD_API_URL || (
    ['127.0.0.1', 'localhost'].includes(window.location.hostname)
        ? 'http://127.0.0.1:5000/api'
        : '/api'
);

// Submit Donor Form
async function submitDonor(event) {
    event.preventDefault();

    const formData = {
        action: 'add_donor',
        donor_name: document.getElementById('donorName').value,
        blood_group: document.getElementById('donorBloodGroup').value,
        contact_number: document.getElementById('donorContact').value,
        email: document.getElementById('donorEmail').value || null,
        date_of_birth: document.getElementById('donorDOB').value || null,
        gender: document.getElementById('donorGender').value || null,
        address: document.getElementById('donorAddress').value,
        medical_report: document.getElementById('donorMedicalReport').value || null
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            showMessage(`Donor registered successfully! Donor ID: ${result.donor_id}`, 'success');
            document.getElementById('donorForm').reset();
        } else {
            showMessage(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        showMessage('Error connecting to server. Please check your connection.', 'error');
        console.error('Error:', error);
    }
}

// Submit Patient Form
async function submitPatient(event) {
    event.preventDefault();

    const formData = {
        action: 'add_patient',
        patient_name: document.getElementById('patientName').value,
        blood_group: document.getElementById('patientBloodGroup').value,
        disease: document.getElementById('patientDisease').value,
        contact_number: document.getElementById('patientContact').value || null,
        address: document.getElementById('patientAddress').value || null,
        date_of_birth: document.getElementById('patientDOB').value || null,
        gender: document.getElementById('patientGender').value || null,
        hospital_name: document.getElementById('patientHospital').value || null,
        admission_date: document.getElementById('patientAdmission').value || null
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            showMessage(`Patient registered successfully! Patient ID: ${result.patient_id}`, 'success');
            document.getElementById('patientForm').reset();
        } else {
            showMessage(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        showMessage('Error connecting to server. Please check your connection.', 'error');
        console.error('Error:', error);
    }
}

// Submit Blood Bank Form
async function submitBloodBank(event) {
    event.preventDefault();

    const formData = {
        action: 'add_blood_bank',
        bank_name: document.getElementById('bankName').value,
        contact_number: document.getElementById('bankContact').value,
        email: document.getElementById('bankEmail').value || null,
        city: document.getElementById('bankCity').value || null,
        state: document.getElementById('bankState').value || null,
        address: document.getElementById('bankAddress').value
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            showMessage(`Blood Bank registered successfully! Bank ID: ${result.blood_bank_id}`, 'success');
            document.getElementById('bloodbankForm').reset();
        } else {
            showMessage(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        showMessage('Error connecting to server. Please check your connection.', 'error');
        console.error('Error:', error);
    }
}

// Submit Donation Form
async function submitDonation(event) {
    event.preventDefault();

    const formData = {
        action: 'add_donation',
        donor_id: document.getElementById('donationDonorId').value,
        blood_bank_id: document.getElementById('donationBloodBankId').value,
        donation_date: document.getElementById('donationDate').value,
        blood_group: document.getElementById('donationBloodGroup').value,
        quantity_ml: document.getElementById('donationQuantity').value,
        donation_type: document.getElementById('donationType').value,
        remarks: document.getElementById('donationRemarks').value || null
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            showMessage(`Donation recorded successfully! Donation ID: ${result.donation_id}`, 'success');
            document.getElementById('donationForm').reset();
        } else {
            showMessage(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        showMessage('Error connecting to server. Please check your connection.', 'error');
        console.error('Error:', error);
    }
}

// Submit Blood Request Form
async function submitRequest(event) {
    event.preventDefault();

    const formData = {
        action: 'add_request',
        patient_id: document.getElementById('requestPatientId').value,
        blood_bank_id: document.getElementById('requestBloodBankId').value,
        blood_group: document.getElementById('requestBloodGroup').value,
        quantity_ml: document.getElementById('requestQuantity').value,
        request_date: document.getElementById('requestDate').value,
        required_by_date: document.getElementById('requestRequiredBy').value || null,
        urgency: document.getElementById('requestUrgency').value,
        remarks: document.getElementById('requestRemarks').value || null
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();

        if (result.success) {
            showMessage(`Blood request submitted successfully! Request ID: ${result.request_id}`, 'success');
            document.getElementById('requestForm').reset();
        } else {
            showMessage(`Error: ${result.message}`, 'error');
        }
    } catch (error) {
        showMessage('Error connecting to server. Please check your connection.', 'error');
        console.error('Error:', error);
    }
}

// Load Blood Banks for dropdown
async function loadBloodBanks() {
    try {
        const response = await fetch(`${API_URL}?action=get_blood_banks`);
        const result = await response.json();

        if (result.success) {
            const select = document.getElementById('filterBloodBank');
            select.innerHTML = '<option value="">All Blood Banks</option>';
            
            result.data.forEach(bank => {
                const option = document.createElement('option');
                option.value = bank.blood_bank_id;
                option.textContent = `${bank.bank_name} - ${bank.city || 'N/A'}`;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading blood banks:', error);
    }
}

// Load Blood Inventory
async function loadInventory() {
    const bloodBankId = document.getElementById('filterBloodBank').value;
    const bloodGroup = document.getElementById('filterBloodGroup').value;
    const minQuantity = Number(document.getElementById('filterMinQuantity').value || 0);
    const resultsDiv = document.getElementById('inventoryResults');
    
    resultsDiv.innerHTML = '<div class="loading"></div> Loading inventory...';

    try {
        let url = `${API_URL}?action=get_inventory`;
        if (bloodBankId) {
            url += `&blood_bank_id=${bloodBankId}`;
        }
        if (bloodGroup) {
            url += `&blood_group=${encodeURIComponent(bloodGroup)}`;
        }

        const response = await fetch(url);
        const result = await response.json();

        if (result.success && result.data.length > 0) {
            const filteredData = result.data.filter(item => Number(item.quantity_ml) >= minQuantity);

            if (filteredData.length === 0) {
                resultsDiv.innerHTML = '<p>No matching inventory for the selected filters.</p>';
                return;
            }

            let html = `
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Blood Bank</th>
                                <th>City</th>
                                <th>Blood Group</th>
                                <th>Quantity (ml)</th>
                                <th>Quantity (L)</th>
                                <th>Availability</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            filteredData.forEach(item => {
                const quantityMl = Number(item.quantity_ml);
                const quantityLiters = (quantityMl / 1000).toFixed(2);
                let availability = 'Critical';

                if (quantityMl >= 3000) {
                    availability = 'Good';
                } else if (quantityMl >= 1000) {
                    availability = 'Low';
                }

                html += `
                    <tr>
                        <td>${item.bank_name}</td>
                        <td>${item.city || 'N/A'}</td>
                        <td><span class="blood-badge">${item.blood_group}</span></td>
                        <td>${quantityMl}</td>
                        <td>${quantityLiters}</td>
                        <td><span class="status-badge ${availability.toLowerCase()}">${availability}</span></td>
                    </tr>
                `;
            });

            html += `
                        </tbody>
                    </table>
                </div>
            `;
            resultsDiv.innerHTML = html;
        } else {
            resultsDiv.innerHTML = '<p>No inventory data available.</p>';
        }
    } catch (error) {
        resultsDiv.innerHTML = '<p>Error loading inventory data.</p>';
        console.error('Error:', error);
    }
}

// Set today's date as default for date inputs
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date().toISOString().split('T')[0];
    
    if (document.getElementById('donationDate')) {
        document.getElementById('donationDate').value = today;
    }
    if (document.getElementById('requestDate')) {
        document.getElementById('requestDate').value = today;
    }
    if (document.getElementById('patientAdmission')) {
        document.getElementById('patientAdmission').value = today;
    }
    
    // Load dashboard on page load
    loadDashboard();
});

// Dashboard Data Storage
let dashboardData = {
    donors: [],
    patients: [],
    donations: [],
    requests: [],
    stats: {}
};

let currentDashboardView = 'donors';

// Load all dashboard data
async function loadDashboard() {
    try {
        // Load statistics
        await loadStats();
        
        // Load all data
        await Promise.all([
            loadDonorsData(),
            loadPatientsData(),
            loadDonationsData(),
            loadRequestsData()
        ]);
        
        // Display current view
        showDashboardData(currentDashboardView);
        
        showMessage('Dashboard data loaded successfully', 'success');
    } catch (error) {
        showMessage('Error loading dashboard data', 'error');
        console.error('Dashboard load error:', error);
    }
}

// Load statistics
async function loadStats() {
    try {
        const response = await fetch(`${API_URL}?action=get_stats`);
        const result = await response.json();
        
        if (result.success) {
            dashboardData.stats = result.data;
            
            // Update stat cards
            document.getElementById('totalDonors').textContent = result.data.total_donors;
            document.getElementById('totalPatients').textContent = result.data.total_patients;
            document.getElementById('totalDonations').textContent = result.data.total_donations;
            document.getElementById('totalRequests').textContent = result.data.total_requests;
        }
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Load donors data
async function loadDonorsData() {
    try {
        const response = await fetch(`${API_URL}?action=get_donors`);
        const result = await response.json();
        
        if (result.success) {
            dashboardData.donors = result.data;
        }
    } catch (error) {
        console.error('Error loading donors:', error);
    }
}

// Load patients data
async function loadPatientsData() {
    try {
        const response = await fetch(`${API_URL}?action=get_patients`);
        const result = await response.json();
        
        if (result.success) {
            dashboardData.patients = result.data;
        }
    } catch (error) {
        console.error('Error loading patients:', error);
    }
}

// Load donations data
async function loadDonationsData() {
    try {
        const response = await fetch(`${API_URL}?action=get_donations`);
        const result = await response.json();
        
        if (result.success) {
            dashboardData.donations = result.data;
        }
    } catch (error) {
        console.error('Error loading donations:', error);
    }
}

// Load requests data
async function loadRequestsData() {
    try {
        const response = await fetch(`${API_URL}?action=get_requests`);
        const result = await response.json();
        
        if (result.success) {
            dashboardData.requests = result.data;
        }
    } catch (error) {
        console.error('Error loading requests:', error);
    }
}

// Show dashboard data based on selected tab
function showDashboardData(type, buttonElement = null) {
    currentDashboardView = type;
    
    // Update active tab
    const tabButtons = document.querySelectorAll('.dashboard-tab-btn');
    tabButtons.forEach(btn => btn.classList.remove('active'));

    if (buttonElement) {
        buttonElement.classList.add('active');
    } else {
        const indexMap = {
            donors: 0,
            patients: 1,
            donations: 2,
            requests: 3
        };
        const activeIndex = indexMap[type];
        if (activeIndex !== undefined && tabButtons[activeIndex]) {
            tabButtons[activeIndex].classList.add('active');
        }
    }
    
    const container = document.getElementById('dashboardDataContainer');
    
    switch(type) {
        case 'donors':
            displayDonors(container);
            break;
        case 'patients':
            displayPatients(container);
            break;
        case 'donations':
            displayDonations(container);
            break;
        case 'requests':
            displayRequests(container);
            break;
    }
}

// Display donors table
function displayDonors(container) {
    if (!dashboardData.donors || dashboardData.donors.length === 0) {
        container.innerHTML = '<p>No donors found. Please register donors first.</p>';
        return;
    }
    
    let html = `
        <h3>All Donors (${dashboardData.donors.length})</h3>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Blood Group</th>
                        <th>Contact</th>
                        <th>Email</th>
                        <th>Gender</th>
                        <th>Address</th>
                        <th>Last Donation</th>
                        <th>Eligible</th>
                        <th>Registered</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    dashboardData.donors.forEach(donor => {
        html += `
            <tr>
                <td>${donor.donor_id}</td>
                <td>${donor.donor_name}</td>
                <td><span class="blood-badge">${donor.blood_group}</span></td>
                <td>${donor.contact_number}</td>
                <td>${donor.email || 'N/A'}</td>
                <td>${donor.gender || 'N/A'}</td>
                <td>${donor.address}</td>
                <td>${donor.last_donation_date || 'Never'}</td>
                <td><span class="status-badge ${donor.is_eligible ? 'eligible' : 'not-eligible'}">${donor.is_eligible ? 'Yes' : 'No'}</span></td>
                <td>${formatDate(donor.created_at)}</td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    container.innerHTML = html;
}

// Display patients table
function displayPatients(container) {
    if (!dashboardData.patients || dashboardData.patients.length === 0) {
        container.innerHTML = '<p>No patients found. Please register patients first.</p>';
        return;
    }
    
    let html = `
        <h3>All Patients/Receivers (${dashboardData.patients.length})</h3>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Blood Group</th>
                        <th>Disease</th>
                        <th>Contact</th>
                        <th>Gender</th>
                        <th>Hospital</th>
                        <th>Admission Date</th>
                        <th>Address</th>
                        <th>Registered</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    dashboardData.patients.forEach(patient => {
        html += `
            <tr>
                <td>${patient.patient_id}</td>
                <td>${patient.patient_name}</td>
                <td><span class="blood-badge">${patient.blood_group}</span></td>
                <td>${patient.disease}</td>
                <td>${patient.contact_number || 'N/A'}</td>
                <td>${patient.gender || 'N/A'}</td>
                <td>${patient.hospital_name || 'N/A'}</td>
                <td>${patient.admission_date || 'N/A'}</td>
                <td>${patient.address || 'N/A'}</td>
                <td>${formatDate(patient.created_at)}</td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    container.innerHTML = html;
}

// Display donations table
function displayDonations(container) {
    if (!dashboardData.donations || dashboardData.donations.length === 0) {
        container.innerHTML = '<p>No donations found. Please record donations first.</p>';
        return;
    }
    
    let html = `
        <h3>All Donations (${dashboardData.donations.length})</h3>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Date</th>
                        <th>Donor Name</th>
                        <th>Blood Group</th>
                        <th>Quantity (ml)</th>
                        <th>Type</th>
                        <th>Blood Bank</th>
                        <th>City</th>
                        <th>Status</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    dashboardData.donations.forEach(donation => {
        html += `
            <tr>
                <td>${donation.donation_id}</td>
                <td>${donation.donation_date}</td>
                <td>${donation.donor_name}</td>
                <td><span class="blood-badge">${donation.blood_group}</span></td>
                <td>${donation.quantity_ml}</td>
                <td>${donation.donation_type}</td>
                <td>${donation.bank_name}</td>
                <td>${donation.city || 'N/A'}</td>
                <td><span class="status-badge ${donation.status.toLowerCase()}">${donation.status}</span></td>
                <td>${donation.remarks || '-'}</td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    container.innerHTML = html;
}

// Display blood requests table
function displayRequests(container) {
    if (!dashboardData.requests || dashboardData.requests.length === 0) {
        container.innerHTML = '<p>No blood requests found. Please submit requests first.</p>';
        return;
    }
    
    let html = `
        <h3>All Blood Requests (${dashboardData.requests.length})</h3>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Request Date</th>
                        <th>Patient Name</th>
                        <th>Disease</th>
                        <th>Blood Group</th>
                        <th>Quantity (ml)</th>
                        <th>Blood Bank</th>
                        <th>Required By</th>
                        <th>Urgency</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    dashboardData.requests.forEach(request => {
        html += `
            <tr>
                <td>${request.request_id}</td>
                <td>${request.request_date}</td>
                <td>${request.patient_name}</td>
                <td>${request.disease}</td>
                <td><span class="blood-badge">${request.blood_group}</span></td>
                <td>${request.quantity_ml}</td>
                <td>${request.bank_name} (${request.city || 'N/A'})</td>
                <td>${request.required_by_date || 'N/A'}</td>
                <td><span class="urgency-badge ${request.urgency.toLowerCase()}">${request.urgency}</span></td>
                <td><span class="status-badge ${request.status.toLowerCase()}">${request.status}</span></td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    container.innerHTML = html;
}

// Format date helper
function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}
