pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = '824909831309'
    AWS_REGION     = 'ap-south-1'
    ECR_REPO       = 'devops-sample-app'
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    ECR_URI        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    // NodeJS tool name must match Jenkins Global Tool config
    NODEJS_TOOL    = 'nodejs-lts'
    // Jenkins credentials id for AWS
    AWS_CREDS_ID   = 'aws-creds'
    // ECS deployment targets (discovered)
    ECS_CLUSTER    = 'arn:aws:ecs:ap-south-1:824909831309:cluster/devops-sample-cluster'
    ECS_SERVICE    = 'arn:aws:ecs:ap-south-1:824909831309:service/devops-sample-cluster/devops-sample-task-service-4s8y60r6'
    TASK_FAMILY    = 'devops-sample-task'
    CONTAINER_NAME = 'devops-sample-container'
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
      tools { nodejs "${NODEJS_TOOL}" }
      steps {
        sh 'node -v && npm -v'
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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDS_ID]]) {
          sh "aws --version"
          sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        }
      }
    }

    stage('Push Image') {
      steps {
        sh "aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} || aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION}"
        sh "docker push ${ECR_URI}:${IMAGE_TAG}"
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
