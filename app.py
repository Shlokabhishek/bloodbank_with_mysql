import datetime
import os
from decimal import Decimal
from pathlib import Path

import mysql.connector
from dotenv import load_dotenv
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from mysql.connector import pooling


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

app = Flask(__name__, static_folder=str(BASE_DIR))
CORS(app)

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "database": os.getenv("DB_NAME", "blood_bank_db"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASS", ""),
}

POOL = None


def get_pool():
    global POOL
    if POOL is None:
        POOL = pooling.MySQLConnectionPool(pool_name="blood_bank_pool", pool_size=5, **DB_CONFIG)
    return POOL


def _normalize_value(value):
    if isinstance(value, (datetime.date, datetime.datetime)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    return value


def _normalize_rows(rows):
    return [{k: _normalize_value(v) for k, v in row.items()} for row in rows]


def _ok(data=None, message=None, extra=None):
    payload = {"success": True}
    if data is not None:
        payload["data"] = data
    if message:
        payload["message"] = message
    if extra:
        payload.update(extra)
    return jsonify(payload)


def _fail(message, status_code=400):
    return jsonify({"success": False, "message": message}), status_code


def run_select(sql, params=None):
    conn = get_pool().get_connection()
    try:
        with conn.cursor(dictionary=True) as cursor:
            cursor.execute(sql, params or ())
            return _normalize_rows(cursor.fetchall())
    finally:
        conn.close()


def run_insert(sql, params):
    conn = get_pool().get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, params)
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()


@app.get("/")
def root():
    return send_from_directory(BASE_DIR, "index.html")


@app.get("/<path:filename>")
def static_files(filename):
    file_path = BASE_DIR / filename
    if file_path.exists() and file_path.is_file():
        return send_from_directory(BASE_DIR, filename)
    return _fail("File not found", 404)


@app.route("/api", methods=["GET", "POST", "OPTIONS"])
def api():
    if request.method == "OPTIONS":
        return "", 204

    try:
        if request.method == "GET":
            action = request.args.get("action", "")
            return handle_get(action)

        data = request.get_json(silent=True) or {}
        action = data.get("action", "")
        return handle_post(action, data)
    except mysql.connector.Error as db_error:
        return _fail(f"Database error: {db_error.msg}", 500)
    except Exception as exc:
        return _fail(f"Server error: {exc}", 500)


def handle_get(action):
    if action == "get_blood_banks":
        return _ok(data=get_blood_banks())
    if action == "get_inventory":
        blood_bank_id = request.args.get("blood_bank_id")
        blood_group = request.args.get("blood_group")
        return _ok(data=get_inventory(blood_bank_id, blood_group))
    if action == "get_donors":
        return _ok(data=get_donors())
    if action == "get_patients":
        return _ok(data=get_patients())
    if action == "get_donations":
        return _ok(data=get_donations())
    if action == "get_requests":
        return _ok(data=get_requests())
    if action == "get_stats":
        return _ok(data=get_stats())
    return _fail("Invalid action", 400)


def handle_post(action, data):
    if action == "add_donor":
        donor_id = add_donor(data)
        return _ok(message="Donor registered successfully", extra={"donor_id": donor_id})
    if action == "add_patient":
        patient_id = add_patient(data)
        return _ok(message="Patient registered successfully", extra={"patient_id": patient_id})
    if action == "add_blood_bank":
        blood_bank_id = add_blood_bank(data)
        return _ok(message="Blood Bank registered successfully", extra={"blood_bank_id": blood_bank_id})
    if action == "add_donation":
        donation_id = add_donation(data)
        return _ok(message="Donation recorded successfully", extra={"donation_id": donation_id})
    if action == "add_request":
        request_id = add_request(data)
        return _ok(message="Blood request submitted successfully", extra={"request_id": request_id})
    return _fail("Invalid action", 400)


def get_blood_banks():
    sql = """
        SELECT blood_bank_id, bank_name, city, address, contact_number
        FROM Blood_Bank
        ORDER BY bank_name
    """
    return run_select(sql)


def get_inventory(blood_bank_id=None, blood_group=None):
    sql = """
        SELECT bb.bank_name, bb.city, bi.blood_group, bi.quantity_ml, bi.last_updated
        FROM Blood_Inventory bi
        JOIN Blood_Bank bb ON bi.blood_bank_id = bb.blood_bank_id
    """
    params = []
    where_clauses = []

    if blood_bank_id:
        where_clauses.append("bi.blood_bank_id = %s")
        params.append(int(blood_bank_id))

    if blood_group:
        where_clauses.append("bi.blood_group = %s")
        params.append(blood_group)

    if where_clauses:
        sql += " WHERE " + " AND ".join(where_clauses)

    sql += " ORDER BY bb.bank_name, bi.blood_group"
    return run_select(sql, tuple(params))


def add_donor(data):
    sql = """
        INSERT INTO Donor (
            donor_name, blood_group, medical_report, address, contact_number,
            email, date_of_birth, gender, is_eligible
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, TRUE)
    """
    params = (
        data.get("donor_name"),
        data.get("blood_group"),
        data.get("medical_report"),
        data.get("address"),
        data.get("contact_number"),
        data.get("email"),
        data.get("date_of_birth"),
        data.get("gender"),
    )
    return run_insert(sql, params)


def add_patient(data):
    sql = """
        INSERT INTO Patient (
            patient_name, blood_group, disease, contact_number, address,
            date_of_birth, gender, hospital_name, admission_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    params = (
        data.get("patient_name"),
        data.get("blood_group"),
        data.get("disease"),
        data.get("contact_number"),
        data.get("address"),
        data.get("date_of_birth"),
        data.get("gender"),
        data.get("hospital_name"),
        data.get("admission_date"),
    )
    return run_insert(sql, params)


def add_blood_bank(data):
    sql = """
        INSERT INTO Blood_Bank (
            bank_name, address, contact_number, email, city, state
        ) VALUES (%s, %s, %s, %s, %s, %s)
    """
    params = (
        data.get("bank_name"),
        data.get("address"),
        data.get("contact_number"),
        data.get("email"),
        data.get("city"),
        data.get("state"),
    )
    return run_insert(sql, params)


def add_donation(data):
    sql = """
        INSERT INTO Donation (
            donor_id, blood_bank_id, donation_date, blood_group,
            quantity_ml, donation_type, status, remarks
        ) VALUES (%s, %s, %s, %s, %s, %s, 'Pending', %s)
    """
    params = (
        int(data.get("donor_id")),
        int(data.get("blood_bank_id")),
        data.get("donation_date"),
        data.get("blood_group"),
        int(data.get("quantity_ml")),
        data.get("donation_type"),
        data.get("remarks"),
    )
    return run_insert(sql, params)


def add_request(data):
    sql = """
        INSERT INTO Blood_Request (
            patient_id, blood_bank_id, blood_group, quantity_ml,
            request_date, required_by_date, urgency, status, remarks
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, 'Pending', %s)
    """
    params = (
        int(data.get("patient_id")),
        int(data.get("blood_bank_id")),
        data.get("blood_group"),
        int(data.get("quantity_ml")),
        data.get("request_date"),
        data.get("required_by_date"),
        data.get("urgency"),
        data.get("remarks"),
    )
    return run_insert(sql, params)


def get_donors():
    sql = """
        SELECT donor_id, donor_name, blood_group, contact_number, email,
               date_of_birth, gender, address, last_donation_date, is_eligible, created_at
        FROM Donor
        ORDER BY created_at DESC
    """
    rows = run_select(sql)
    for row in rows:
        row["is_eligible"] = bool(row.get("is_eligible"))
    return rows


def get_patients():
    sql = """
        SELECT patient_id, patient_name, blood_group, disease, contact_number,
               address, date_of_birth, gender, hospital_name, admission_date, created_at
        FROM Patient
        ORDER BY created_at DESC
    """
    return run_select(sql)


def get_donations():
    sql = """
        SELECT d.donation_id, d.donation_date, d.blood_group, d.quantity_ml,
               d.donation_type, d.status, d.remarks,
               don.donor_name, don.contact_number AS donor_contact,
               bb.bank_name, bb.city
        FROM Donation d
        JOIN Donor don ON d.donor_id = don.donor_id
        JOIN Blood_Bank bb ON d.blood_bank_id = bb.blood_bank_id
        ORDER BY d.donation_date DESC
    """
    return run_select(sql)


def get_requests():
    sql = """
        SELECT br.request_id, br.blood_group, br.quantity_ml, br.request_date,
               br.required_by_date, br.urgency, br.status, br.remarks,
               p.patient_name, p.disease, p.contact_number AS patient_contact,
               bb.bank_name, bb.city
        FROM Blood_Request br
        JOIN Patient p ON br.patient_id = p.patient_id
        JOIN Blood_Bank bb ON br.blood_bank_id = bb.blood_bank_id
        ORDER BY br.request_date DESC
    """
    return run_select(sql)


def get_stats():
    totals = {}
    totals["total_donors"] = run_select("SELECT COUNT(*) AS total FROM Donor")[0]["total"]
    totals["total_patients"] = run_select("SELECT COUNT(*) AS total FROM Patient")[0]["total"]
    totals["total_donations"] = run_select("SELECT COUNT(*) AS total FROM Donation")[0]["total"]
    totals["total_requests"] = run_select("SELECT COUNT(*) AS total FROM Blood_Request")[0]["total"]
    return totals


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=True)
