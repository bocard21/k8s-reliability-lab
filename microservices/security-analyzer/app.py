from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health/live")
def liveness():
    return jsonify({"status": "alive"}), 200

@app.route("/health/ready")
def readiness():
    return jsonify({"status": "ready"}), 200

@app.route("/security")
def security():
    return jsonify({"service": "security-analyzer", "status": "running"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
