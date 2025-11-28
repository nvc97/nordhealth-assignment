# Nordhealth-assignment

This repository contains the code for a simple web app built with Flask. The app is containerized using Docker and is designed to be pushed to AWS ECR (Elastic Container Registry) and automatically deployed to an EC2 instance using GitHub Actions.


The app exposes two endpoints:
- `"/"` returns a "Hello World!" message along with the current request duration time.
- `"/metrics"` provides Prometheus metrics.

## Local Development
To build and run the Docker container locally, use the following commands:
```
docker build -t nordhealth-app:latest .
docker run --rm -p 5000:5000 nordhealth-app:latest
```
You can then access the app at `http://localhost:5000/` and the metrics at `http://localhost:5000/metrics`.

## GitHub Actions Deployment
The GitHub Actions workflow is defined in `.github/workflows/deploy.yml`. It builds, tags, and pushes the Docker image to AWS ECR, then deploys it to an EC2 instance.

![gh-actions-success](/figures/github-actions-success.png)

When the deployment is successful, the app will be running on the specified EC2 instance, accessible via its public IP or domain name. Verification after deploy:

![hello-world](/figures/hello-world.png)

![metrics](/figures/metrics.png)

The metrics endpoint shows the Prometheus metrics, including the request duration `Histogram` and the `Gauge` for latest request duration.

## Terraform AWS Infrastructure
The creation of the AWS infrastructure is managed using Terraform. The Terraform configuration files are located in the [aws-resources-terraform](aws-resources-terraform) directory. Below is a successful apply of the Terraform configuration:

![tf-creation-success](/figures/tf-creation-success.png)
