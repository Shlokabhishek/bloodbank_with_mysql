import os
from pathlib import Path

import mysql.connector
from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_NAME = os.getenv("DB_NAME", "blood_bank_db")
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "")

RESET_OBJECTS_SQL = [
    "DROP VIEW IF EXISTS vw_blood_stock_summary",
    "DROP VIEW IF EXISTS vw_eligible_donors",
    "DROP VIEW IF EXISTS vw_pending_requests",
    "DROP VIEW IF EXISTS vw_donation_history",
    "DROP TRIGGER IF EXISTS trg_update_inventory_after_donation",
    "DROP TRIGGER IF EXISTS trg_update_inventory_after_request",
    "DROP TRIGGER IF EXISTS trg_update_donor_last_donation",
    "DROP PROCEDURE IF EXISTS sp_check_blood_availability",
    "DROP PROCEDURE IF EXISTS sp_get_compatible_donors",
]


def parse_mysql_script(script_text):
    statements = []
    delimiter = ";"
    buffer = ""

    for raw_line in script_text.splitlines():
        line = raw_line.strip()

        if not line or line.startswith("--"):
            continue

        upper = line.upper()
        if upper.startswith("DELIMITER "):
            delimiter = line.split(" ", 1)[1].strip()
            continue

        buffer += raw_line + "\n"

        if buffer.rstrip().endswith(delimiter):
            stmt = buffer.rstrip()[: -len(delimiter)].strip()
            if stmt:
                statements.append(stmt)
            buffer = ""

    leftover = buffer.strip()
    if leftover:
        statements.append(leftover)

    return statements


def run_script(cursor, script_path):
    content = script_path.read_text(encoding="utf-8")
    statements = parse_mysql_script(content)

    for stmt in statements:
        cursor.execute(stmt)
        if cursor.with_rows:
            cursor.fetchall()


if __name__ == "__main__":
    schema_path = BASE_DIR / "schema.sql"
    sample_path = BASE_DIR / "sample_data.sql"

    root_conn = mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASS,
    )
    try:
        with root_conn.cursor() as cursor:
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
        root_conn.commit()
    finally:
        root_conn.close()

    db_conn = mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
    )
    try:
        with db_conn.cursor() as cursor:
            for stmt in RESET_OBJECTS_SQL:
                cursor.execute(stmt)
            run_script(cursor, schema_path)
        db_conn.commit()
        print("Schema initialized successfully.")

        try:
            with db_conn.cursor() as cursor:
                run_script(cursor, sample_path)
            db_conn.commit()
            print("Sample data imported successfully.")
        except mysql.connector.Error as sample_error:
            db_conn.rollback()
            print(f"Sample data import warning: {sample_error}")
            print("Schema is ready; you can still use the app and add records from the UI.")
    finally:
        db_conn.close()
