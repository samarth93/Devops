# Jenkins CI/CD Pipeline Documentation

## Overview
This document provides visual documentation of the Jenkins CI/CD pipeline for the DevOps Node.js application, showing each stage from GitHub webhook to ECS deployment.

## Pipeline Architecture

**Repository**: https://github.com/samarth93/Devops.git  
**Jenkins Job**: devops-multibranch  
**Branches**: main, dev  
**Target**: AWS ECS Fargate via ECR  

## Pipeline Stages

### 1. **Checkout Stage**
- **Purpose**: Clone the repository from GitHub
- **Actions**: 
  - Fetch latest code from main/dev branch
  - Checkout specific commit that triggered the build
  - Prepare workspace for build process

### 2. **Setup Node Stage**
- **Purpose**: Configure Node.js environment
- **Actions**:
  - Use NodeJS tool: `nodejs-lts` (Node 18.x)
  - Verify Node.js and npm versions
  - Prepare for dependency installation

### 3. **Build & Test Stage**
- **Purpose**: Install dependencies and run tests
- **Actions**:
  - Run `npm install` to install dependencies
  - Execute `npm test` to run application tests
  - Validate code quality and functionality

### 4. **Docker Build Stage**
- **Purpose**: Create containerized application image
- **Actions**:
  - Build Docker image using Dockerfile
  - Tag image: `824909831309.dkr.ecr.ap-south-1.amazonaws.com/devops-sample-app:${BUILD_NUMBER}`
  - Verify Docker build success

### 5. **Login to ECR Stage**
- **Purpose**: Authenticate with AWS Elastic Container Registry
- **Actions**:
  - Use AWS credentials (ID: aws-creds)
  - Get ECR login token via AWS CLI
  - Authenticate Docker client with ECR

### 6. **Push Image Stage**
- **Purpose**: Upload Docker image to ECR repository
- **Actions**:
  - Ensure ECR repository exists (create if needed)
  - Push tagged Docker image to ECR
  - Verify successful image upload

### 7. **Deploy to ECS Stage**
- **Purpose**: Deploy new image to ECS Fargate service
- **Actions**:
  - Fetch current ECS task definition
  - Update container image to new ECR image
  - Register new task definition revision
  - Update ECS service with new task definition

### 8. **Post-Build Verification**
- **Purpose**: Verify deployment success and provide status
- **Actions**:
  - Query ECS service status
  - Display running vs desired task counts
  - Show current task definition ARN
  - Report deployment outcome

## AWS Resources

### ECR Repository
- **URI**: `824909831309.dkr.ecr.ap-south-1.amazonaws.com/devops-sample-app`
- **Region**: ap-south-1
- **Purpose**: Store Docker images for deployment

### ECS Configuration
- **Cluster**: `devops-sample-cluster`
- **Service**: `devops-sample-task-service-4s8y60r6`
- **Task Family**: `devops-sample-task`
- **Container**: `devops-sample-container`
- **Launch Type**: Fargate
- **Public Access**: Yes (via Public IP)

## Application Details

### Node.js Application
- **Framework**: Express.js
- **Port**: 3000
- **Function**: Serves Swayatt logo image
- **Entry Point**: app.js
- **Dependencies**: express ^4.18.2

### Docker Configuration
- **Base Image**: node:18-alpine
- **Working Directory**: /usr/src/app
- **Exposed Port**: 3000
- **Start Command**: npm start

## Triggers and Automation

### GitHub Webhook
- **URL**: `http://<jenkins-host>:8080/github-webhook/`
- **Events**: Push events on main and dev branches
- **Response**: Automatic pipeline execution

### Build Triggers
- **Source**: GitHub push events
- **Branches**: main, dev
- **Frequency**: On-demand (webhook driven)
- **Build Number**: Auto-incrementing

## Security and Credentials

### AWS Credentials
- **ID**: aws-creds
- **Type**: AWS Access Key/Secret Key
- **Scope**: Global
- **Permissions**: ECR, ECS, CloudWatch access

### Jenkins Security
- **User**: admin
- **Authentication**: Username/password
- **Authorization**: Full administrative access

## Pipeline Features

### Error Handling
- **jq Installation**: Auto-installs if missing on agent
- **Container Updates**: Updates by container name (not index)
- **ECR Repository**: Creates repository if it doesn't exist
- **Build Failures**: Fails fast with detailed error messages

### Monitoring and Logging
- **Console Output**: Detailed logs for each stage
- **AWS CLI Output**: Service status and task information
- **Timestamps**: Build duration and completion times
- **Status Reporting**: Success/failure notifications

## Live Application

### Deployment Result
- **Status**: ✅ ACTIVE and RUNNING
- **Tasks**: 1/1 desired tasks running
- **Public URL**: http://15.206.211.187:3000
- **Response**: HTTP 200 OK serving logo image

### Verification Steps
1. **Local Build**: ✅ Docker image builds successfully
2. **ECR Push**: ✅ Image available in ECR repository
3. **ECS Deploy**: ✅ Service updated with new task definition
4. **Health Check**: ✅ Application responds with HTTP 200
5. **Content Delivery**: ✅ Logo image served correctly

---

*Generated on: September 13, 2025*  
*Pipeline Status: ✅ Fully Operational*  
*Last Build: Successful deployment to production*