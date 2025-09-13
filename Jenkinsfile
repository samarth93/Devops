/*
 * DevOps CI/CD Pipeline
 * 
 * This pipeline requires the following environment variables to be set in Jenkins:
 * - AWS_ACCOUNT_ID: Your AWS account ID (12-digit number)
 * - AWS_REGION: AWS region (e.g., us-east-1, ap-south-1)
 * - ECR_REPO: ECR repository name
 * - ECS_CLUSTER: Full ARN of ECS cluster
 * - ECS_SERVICE: Full ARN of ECS service
 * - TASK_FAMILY: ECS task definition family name
 * - CONTAINER_NAME: Container name in task definition
 * - AWS_CREDS_ID: Jenkins credential ID for AWS credentials (optional, uses system creds if not set)
 */

pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = env.AWS_ACCOUNT_ID ?: 'YOUR_AWS_ACCOUNT_ID'
    AWS_REGION     = env.AWS_REGION ?: 'YOUR_AWS_REGION'
    ECR_REPO       = env.ECR_REPO ?: 'YOUR_ECR_REPOSITORY_NAME'
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    ECR_URI        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    // NodeJS tool (using system Node.js instead)
    // NODEJS_TOOL    = 'nodejs-lts'
    // Jenkins credentials id for AWS
    AWS_CREDS_ID   = env.AWS_CREDS_ID ?: 'aws-creds'
    // ECS deployment targets - set these as environment variables
    ECS_CLUSTER    = env.ECS_CLUSTER ?: 'arn:aws:ecs:YOUR_REGION:YOUR_ACCOUNT_ID:cluster/YOUR_CLUSTER_NAME'
    ECS_SERVICE    = env.ECS_SERVICE ?: 'arn:aws:ecs:YOUR_REGION:YOUR_ACCOUNT_ID:service/YOUR_CLUSTER_NAME/YOUR_SERVICE_NAME'
    TASK_FAMILY    = env.TASK_FAMILY ?: 'YOUR_TASK_FAMILY'
    CONTAINER_NAME = env.CONTAINER_NAME ?: 'YOUR_CONTAINER_NAME'
  }

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Node') {
      steps {
        sh '''
          echo "Using system Node.js..."
          node -v && npm -v || {
            echo "Node.js not found, installing via snap..."
            sudo snap install node --classic
            node -v && npm -v
          }
        '''
      }
    }

    stage('Build & Test') {
      steps {
        sh 'npm install'
        sh 'npm test'
      }
    }

    stage('Docker Build') {
      steps {
        script {
          sh "docker version"
          sh "docker build -t ${ECR_URI}:${IMAGE_TAG} ."
        }
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          echo "Using system AWS credentials..."
          aws --version
          aws sts get-caller-identity
          aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
        '''
      }
    }

    stage('Push Image') {
      steps {
        sh '''
          aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} || aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION}
          docker push ${ECR_URI}:${IMAGE_TAG}
        '''
      }
    }

    stage('Deploy to ECS') {
      steps {
        script {
          // Ensure jq is available
          sh '''
            set -e
            if ! command -v jq >/dev/null 2>&1; then
              echo "jq not found; attempting to install..."
              if command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y jq; 
              elif command -v yum >/dev/null 2>&1; then sudo yum install -y jq; 
              elif command -v apk >/dev/null 2>&1; then sudo apk add --no-cache jq; 
              else echo "Package manager not found; please install jq manually on the Jenkins agent"; exit 1; fi
            fi
          '''
          // Fetch current task definition JSON
          sh '''
            set -euo pipefail
            aws ecs describe-task-definition --task-definition ${TASK_FAMILY} --region ${AWS_REGION} \
              --query 'taskDefinition' > taskdef.json
          '''

          // Update image in container definitions and register new revision
          sh '''
            set -euo pipefail
            NEW_IMAGE="${ECR_URI}:${IMAGE_TAG}"
            cat taskdef.json | \
              jq --arg NAME "${CONTAINER_NAME}" --arg IMG "$NEW_IMAGE" \
                 '.containerDefinitions |= (map(if .name == $NAME then .image = $IMG else . end)) \
                  | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)' \
              > taskdef-updated.json

            aws ecs register-task-definition --region ${AWS_REGION} \
              --cli-input-json file://taskdef-updated.json \
              --query 'taskDefinition.taskDefinitionArn' --output text > newTaskDefArn.txt
          '''

          // Update ECS service to use the new task definition
          sh '''
            set -euo pipefail
            NEW_ARN=$(cat newTaskDefArn.txt)
            aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} \
              --task-definition "$NEW_ARN" --region ${AWS_REGION}
          '''
        }
      }
    }
  }

  post {
    always {
      echo 'Build finished. Gathering deployment status...'
      script {
        sh '''
          set -e
          aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --region ${AWS_REGION} \
            --query 'services[0].{Service:serviceName,Status:status,Running:runningCount,Desired:desiredCount,TaskDef:taskDefinition}'
        '''
      }
    }
    success {
      echo "Deployment successful. Image: ${ECR_URI}:${IMAGE_TAG}"
    }
    failure {
      echo 'Build or deployment failed. Check logs above.'
    }
  }
}
