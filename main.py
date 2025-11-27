from flask import Flask
import time
from prometheus_client import generate_latest, CollectorRegistry, Histogram, Gauge, disable_created_metrics

registry = CollectorRegistry()

disable_created_metrics()

app = Flask(__name__)

# Create a histogram to track request durations
request_duration = Histogram('request_duration_seconds',
    'Duration of HTTP requests in seconds',
    buckets=[0.000001, 0.000002, 0.000003, 0.000005, 0.0001], registry=registry)

# Create a gauge to track instantaneous duration of the last request
last_request_duration = Gauge('last_request_duration_seconds',
    'Duration of the most recent HTTP request in seconds', registry=registry)

@app.route('/metrics')
def metrics():
    # Expose Prometheus metrics
    return generate_latest(registry), 200, {'Content-Type': 'text/plain; charset=utf-8'}
    
@app.route('/')
def hello_world():
    # Start timing the request
    start_time = time.time()

    response = "<h1>Hello World!</h1>"

    # End timing the request
    duration = time.time() - start_time
    request_duration.observe(duration)
    last_request_duration.set(duration)

    # Print the duration to the response
    response += f"<p>Request duration: {duration:.6f} seconds</p>"

    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)