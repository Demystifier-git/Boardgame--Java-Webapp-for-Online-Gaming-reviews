  Java Spring Boot Board Game Application – AWS DevOps Deployment
  Project Overview

This project is an end-to-end deployment of a Java Spring Boot Board Game application on AWS, designed with a strong focus on scalability, security, automation, and observability.

The main goal was to build a production-ready, cloud-native environment that follows modern DevOps best practices — from infrastructure provisioning and CI/CD to monitoring, logging, and performance testing.

This repository showcases how all these components come together to deliver a self-scaling, secure, and observable application running on Kubernetes.

 Architecture & DevOps Stack

The application is fully containerized and deployed on AWS using the following technologies:

  Cloud & Infrastructure
Amazon EKS – Kubernetes orchestration and application deployment
Terraform – Infrastructure as Code for provisioning and management
Amazon VPC & Route 53 – Secure networking and DNS routing
Amazon RDS (MySQL) – Managed relational database backend
AWS Lambda – Automated database scaling operations

 Containerization & CI/CD
Docker – Application containerization
Amazon ECR – Container image storage
GitHub Actions – Automated CI/CD pipeline for build and deployment

 Monitoring, Logging & Observability
Prometheus – Metrics collection
Grafana – Visualization and dashboards
Node Exporter – Node-level metrics
Blackbox Exporter – Endpoint and availability monitoring
Splunk – Centralized log aggregation and analysis

 Scaling & Performance
KEDA – Event-driven autoscaling based on real-time metrics
k6 – Load testing and performance validation

 Security
Snyk – Vulnerability scanning and security checks

 CI/CD Workflow

Code changes are pushed to GitHub

GitHub Actions builds the application

Docker images are created and pushed to Amazon ECR

Kubernetes manifests are applied to EKS

Monitoring, logging, and scaling components automatically observe and adapt to traffic

 Key Outcomes

Fully automated infrastructure and deployment pipeline

Secure and isolated AWS networking setup

Horizontal pod autoscaling based on real-time metrics

Centralized logging and detailed observability

Load-tested and performance-validated application

Production-grade DevOps and cloud architecture

 What I Learned

This project allowed me to bring together my skills in:

DevOps engineering

AWS cloud services

Kubernetes and container orchestration

Monitoring, logging, and alerting

Performance optimization and scaling strategies

I’m proud of the outcome and the real-world DevOps experience gained from building and deploying this system end-to-end.

  Contact

If you’d like to discuss this project, DevOps practices, or potential collaboration, feel free to reach out.
