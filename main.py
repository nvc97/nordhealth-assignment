from flask import Flask
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

@app.route('/metrics')
def metrics():
    # Expose Prometheus metrics
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/')
def hello_world():
    return "<h1>Hello World!</h1>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)