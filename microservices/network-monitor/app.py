import os
from contextlib import closing

import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
@app.get("/health/live")
def liveness():
    return jsonify(status="alive"), 200


@app.get("/health/ready")
def readiness():
    try:
        with closing(psycopg2.connect(
            host=os.environ["DB_HOST"],
            dbname=os.environ.get("DB_NAME", "techsafe_db"),
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
            connect_timeout=2,
        )) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
    except (psycopg2.Error, KeyError):
        app.logger.warning("Database readiness check failed")
        return jsonify(status="not_ready", dependency="postgres"), 503
    return jsonify(status="ready"), 200


@app.get("/monitor")
def monitor():
    # Demo endpoint, not a network scanner or monitoring agent.
    return jsonify(service="network-monitor", status="running"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
