🚀 Jenkins Terraform Kubernetes CI/CD Pipeline

📌 Overview

This repository demonstrates an end-to-end CI/CD pipeline where every code push to GitHub automatically:

Triggers a Jenkins pipeline

Builds and pushes a Docker image

Provisions infrastructure using Terraform

Deploys the application to Kubernetes

This project showcases real-world DevOps / SRE practices used in production environments.

🧰 Tech Stack

Version Control: GitHub

CI/CD: Jenkins

Containerization: Docker

Infrastructure as Code: Terraform

Container Orchestration: Kubernetes

Cloud (Optional): AWS (EKS compatible)


Directory structure of this project:
------------------------------------
├── Jenkinsfile              # Jenkins CI/CD pipeline
├── Dockerfile               # Application Docker image
├── app.py                   # Sample Flask application
├── requirements.txt         # Python dependencies
├── terraform/               # Infrastructure provisioning
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── k8s/                     # Kubernetes manifests
    ├── deployment.yaml
    └── service.yaml
