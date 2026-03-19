# Blood Bank Management System (Python + MySQL)

This project is now fully based on Python (Flask) and MySQL.

## Stack
- Backend: Flask
- Database: MySQL
- Frontend: HTML, CSS, JavaScript

## Project Files
- `app.py`: Flask app and API endpoints
- `init_db.py`: Initializes database/schema/sample data
- `index.html`, `script.js`, `style.css`: Frontend
- `schema.sql`, `sample_data.sql`, `useful_queries.sql`: SQL scripts
- `.env`: Local database credentials
- `.env.example`: Environment template
- `requirements.txt`: Python dependencies

## Setup
1. Create and activate virtual environment:
   - PowerShell:
     ```powershell
     python -m venv .venv
     .\.venv\Scripts\Activate.ps1
     ```
2. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```
3. Configure `.env` (already created in this project):
   - `DB_HOST=127.0.0.1`
   - `DB_PORT=3306`
   - `DB_NAME=blood_bank_db`
   - `DB_USER=root`
   - `DB_PASS=<your-password>`
4. Initialize database:
   ```powershell
   python init_db.py
   ```
5. Start app:
   ```powershell
   python app.py
   ```
6. Open:
   - `http://127.0.0.1:5000/`

## API Base URL
- `http://127.0.0.1:5000/api`

The frontend is already configured for this endpoint.
