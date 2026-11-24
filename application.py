import os

from flask import Flask, jsonify

app = Flask(__name__)
application = app


@app.get("/")
def index():
    identifier = os.environ.get("CUSTOM_IDENTIFIER", "${custom_identifier}")
    return f"Hello from {identifier}!"


@app.get("/health")
def health():
    return jsonify(status="healthy")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
