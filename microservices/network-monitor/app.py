from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
@app.route("/health/live")
def liveness():
    return jsonify({"status": "alive"}), 200

@app.route("/health/ready")
def readiness():
    return jsonify({"status": "ready"}), 200

@app.route("/monitor")
def monitor():
    return jsonify({"service": "network-monitor", "status": "running"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
