pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = '814820107207'
        AWS_DEFAULT_REGION = 'ap-south-2'
        IMAGE_REPO_NAME = 'insurance-app'
        IMAGE_TAG = 'v1'
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/sunaofficials/MlOps-Santanu-insurance-predictor.git'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} ./app"
                }
            }
        }
        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-sant', region: 'ap-south-2') {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }
    }
}
