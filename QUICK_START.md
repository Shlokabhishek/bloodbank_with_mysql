# Quick Start (Python + MySQL)

## 1) Activate environment
```powershell
.\.venv\Scripts\Activate.ps1
```

## 2) Install packages
```powershell
pip install -r requirements.txt
```

## 3) Set database credentials
Edit `.env`:
- `DB_HOST=127.0.0.1`
- `DB_PORT=3306`
- `DB_NAME=blood_bank_db`
- `DB_USER=root`
- `DB_PASS=your_mysql_password`

## 4) Initialize database
```powershell
python init_db.py
```

## 5) Run backend
```powershell
python app.py
```

## 6) Open app
- `http://127.0.0.1:5000/`

## Verify API
```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:5000/api?action=get_stats" -UseBasicParsing
```

## Common Fixes
- `ModuleNotFoundError`: ensure `.venv` is activated and run `pip install -r requirements.txt`.
- MySQL access denied: verify `DB_USER` and `DB_PASS` in `.env`.
- Unknown database: run `python init_db.py`.

## Deploy to Vercel
1. Push project to GitHub.
2. Import repo in Vercel.
3. Add env vars in Vercel settings: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`.
4. Deploy.

Note: your MySQL must be externally reachable by Vercel.
