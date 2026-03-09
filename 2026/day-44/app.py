import os
import time
import psutil
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

# --- Configuration from Environment Variables ---
DB_HOST = os.getenv('DB_HOST', 'db')
DB_NAME = os.getenv('DB_NAME', 'health_db')
DB_USER = os.getenv('DB_USER', 'admin')
DB_PASS = os.getenv('DB_PASS', 'secret')

def init_db():
    """Ensure the table exists for our metrics."""
    try:
        conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
        cur = conn.cursor()
        cur.execute('''
            CREATE TABLE IF NOT EXISTS system_stats (
                id SERIAL PRIMARY KEY,
                cpu_percent FLOAT,
                ram_percent FLOAT,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Waiting for DB... {e}")

@app.route('/')
def home():
    """Welcome page."""
    return {
        "message": "Welcome to the System Health Monitor API!",
        "endpoints": {
            "record_metrics": "/status",
            "view_history": "/history"
        }
    }, 200

@app.route('/status')
def status():
    """Captures CPU/RAM and saves to the Database."""
    cpu = psutil.cpu_percent(interval=1)
    ram = psutil.virtual_memory().percent
    
    try:
        conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
        cur = conn.cursor()
        cur.execute('INSERT INTO system_stats (cpu_percent, ram_percent) VALUES (%s, %s)', (cpu, ram))
        conn.commit()
        cur.close()
        conn.close()
        db_status = "Saved to DB"
    except Exception as e:
        db_status = f"DB Unavailable: {str(e)}"

    return jsonify({
        "cpu_usage_percent": cpu,
        "ram_usage_percent": ram,
        "database_log": db_status
    })

@app.route('/history')
def history():
    """Fetches the last 10 records from the database."""
    try:
        conn = psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
        cur = conn.cursor()
        cur.execute('SELECT cpu_percent, ram_percent, timestamp FROM system_stats ORDER BY timestamp DESC LIMIT 10;')
        rows = cur.fetchall()
        cur.close()
        conn.close()

        # Format the data for JSON
        history_list = []
        for r in rows:
            history_list.append({
                "cpu": r[0],
                "ram": r[1],
                "time": r[2].strftime("%Y-%m-%d %H:%M:%S")
            })
        return jsonify({"history": history_list})
    except Exception as e:
        return jsonify({"error": f"Could not fetch history: {str(e)}"}), 500

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=8080)
