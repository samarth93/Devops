# Logo Server

A simple Express.js web server that serves the Swayatt logo image.

## What is this app?

This is a lightweight Node.js application built with Express.js that serves a single logo image (`logoswayatt.png`) when accessed through a web browser. When you visit the root URL, the server responds by displaying the Swayatt logo.

## Prerequisites

- Node.js (version 12 or higher)
- npm (Node Package Manager)

## Installation

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd "devops task"
   ```
3. Install dependencies:
   ```bash
   npm install
   ```

## How to Start the App

Run the following command:
```bash
npm start
```

The server will start and display:
```
Server running on http://localhost:3000
```

# DevOps CI/CD Pipeline Project

A complete CI/CD pipeline implementation using Jenkins, Docker, AWS ECR, and ECS Fargate for automated deployment of a Node.js application.

## 🌐 Live Application

**Public URL**: [http://43.204.130.22:3000](http://43.204.130.22:3000)

## 📋 Project Overview

This project demonstrates a complete DevOps pipeline that automatically builds, tests, containerizes, and deploys a Node.js application to AWS ECS Fargate whenever code is pushed to the GitHub repository.

### Architecture Overview

```
Developer → GitHub (dev branch) → Jenkins Pipeline → Docker Build → ECR Registry → ECS Fargate → Live Application
```

**Pipeline Flow:**
1. Code pushed to GitHub `dev` branch
2. Jenkins webhook triggers pipeline
3. Application built and tested with Node.js
4. Docker image created and tagged
5. Image pushed to AWS ECR
6. ECS service updated with new image
7. Rolling deployment with zero downtime

## 🛠️ Technologies Used

- **CI/CD**: Jenkins with declarative pipeline
- **Containerization**: Docker with multi-stage builds
- **Cloud Platform**: AWS (ECR, ECS, Fargate)
- **Application**: Node.js with Express.js
- **Version Control**: Git with GitHub integration
- **Infrastructure**: ECS Fargate (serverless containers)

## 📁 Repository Structure

```
├── app.js                     # Node.js application entry point
├── package.json               # Node.js dependencies and scripts
├── package-lock.json          # Locked dependency versions
├── Dockerfile                 # Container build instructions
├── .dockerignore             # Docker build exclusions
├── Jenkinsfile               # CI/CD pipeline definition
├── logoswayatt.png           # Application asset
├── deployment-proof/         # Deployment verification
│   └── DEPLOYMENT.md         # Live deployment details
├── README.md                 # This documentation
└── WRITEUP.md               # Detailed technical write-up
```

## 🚀 Setup & Deployment Guide

### Prerequisites

- AWS Account with ECR and ECS access
- Jenkins server with required plugins
- Docker installed on Jenkins agent
- Node.js runtime environment
- Git repository with webhook capability

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/samarth93/Devops.git
   cd Devops
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Run locally:**
   ```bash
   npm start
   # Application will be available at http://localhost:3000
   ```

4. **Run tests:**
   ```bash
   npm test
   ```

### Docker Deployment

1. **Build Docker image:**
   ```bash
   docker build -t devops-sample-app .
   ```

2. **Run container:**
   ```bash
   docker run -p 3000:3000 devops-sample-app
   ```

### AWS Infrastructure Setup

1. **Create ECR Repository:**
   ```bash
   aws ecr create-repository --repository-name devops-sample-app --region ap-south-1
   ```

2. **Create ECS Cluster:**
   ```bash
   aws ecs create-cluster --cluster-name devops-sample-cluster
   ```

3. **Create ECS Task Definition:**
   - Configure task with Fargate launch type
   - Set memory: 512 MB, CPU: 256 units
   - Map container port 3000 to host port 3000

4. **Create ECS Service:**
   - Desired count: 1
   - Enable public IP assignment
   - Configure security groups for port 3000

### Jenkins Pipeline Setup

1. **Install Required Plugins:**
   - Git plugin
   - Pipeline plugin
   - AWS Credentials plugin
   - Docker Pipeline plugin

2. **Configure AWS Credentials:**
   - Add AWS Access Key ID and Secret Key
   - Set credential ID as `aws-creds`

3. **Create Pipeline Job:**
   - Source: GitHub repository
   - Branch: `dev`
   - Pipeline script from SCM

4. **Configure Webhook:**
   - GitHub webhook URL: `http://<jenkins-host>:8080/github-webhook/`
   - Events: Push events

## 🔧 Pipeline Configuration

The Jenkins pipeline (`Jenkinsfile`) includes 8 stages:

1. **Checkout**: Clone repository from GitHub
2. **Setup Node**: Configure Node.js environment
3. **Build & Test**: Install dependencies and run tests
4. **Docker Build**: Create container image
5. **Login to ECR**: Authenticate with AWS ECR
6. **Push Image**: Upload image to ECR registry
7. **Deploy to ECS**: Update ECS service with new image
8. **Post-Build**: Verify deployment status

## 📊 Deployment Proof

✅ **Live Application**: [http://43.204.130.22:3000](http://43.204.130.22:3000)

**Recent Successful Deployments:**
- Build #6: First successful end-to-end deployment
- Build #7: Consistent deployment verification

**Infrastructure Status:**
- ECS Service: ACTIVE with 1/1 healthy tasks
- Latest Image: `devops-sample-app:7`
- Task Definition: Revision 3 (latest)

For detailed deployment verification, see [deployment-proof/DEPLOYMENT.md](deployment-proof/DEPLOYMENT.md)

## 🏗️ Architecture Diagram

The application follows a modern DevOps architecture with automated CI/CD:

**Development Flow:**
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   GitHub    │───▶│   Jenkins    │───▶│   Docker    │
│ (dev branch)│    │  (Pipeline)  │    │   (Build)   │
└─────────────┘    └──────────────┘    └─────────────┘
                           │                    │
                           ▼                    ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   AWS ECS   │◀───│   AWS ECR    │◀───│   Docker    │
│ (Fargate)   │    │ (Registry)   │    │   (Push)    │
└─────────────┘    └──────────────┘    └─────────────┘
       │
       ▼
┌─────────────┐
│ Live App    │
│ (Public IP) │
└─────────────┘
```

## 📚 Additional Resources

- [WRITEUP.md](WRITEUP.md) - Detailed technical analysis and challenges
- [Jenkinsfile](Jenkinsfile) - Complete pipeline definition
- [Dockerfile](Dockerfile) - Container build instructions
- [deployment-proof/](deployment-proof/) - Deployment verification details

## 🔗 Quick Links

- **Live Application**: http://43.204.130.22:3000
- **GitHub Repository**: https://github.com/samarth93/Devops
- **Docker Image**: `824909831309.dkr.ecr.ap-south-1.amazonaws.com/devops-sample-app:latest`

---

*This project demonstrates end-to-end DevOps automation with modern cloud-native technologies and best practices.*

## Project Structure

```
├── app.js              # Main server file
├── package.json        # Project dependencies and scripts
├── logoswayatt.png     # Logo image file
└── README.md          # This file
```

## Technical Details

- **Framework**: Express.js
- **Port**: 3000
- **Endpoint**: GET `/` - serves the logo image
- **File served**: `logoswayatt.png`
# Devops
# Jenkins Pipeline Documentation - Sun Sep 14 12:10:56 AM IST 2025
