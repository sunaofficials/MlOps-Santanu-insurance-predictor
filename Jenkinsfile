pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '814820107207'
        AWS_DEFAULT_REGION = 'ap-south-2'
        IMAGE_REPO_NAME = 'insurance-app'
        // Use build number to ensure every image has a unique version
        IMAGE_TAG = "v${BUILD_NUMBER}" 
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Ensure branch is set to 'main'
                git branch: 'main', credentialsId: 'git-sant', url: 'https://github.com/sunaofficials/MlOps-Santanu-insurance-predictor.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build from the /app directory where your Dockerfile lives
                    sh "docker build -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} ./app"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                // Authenticate and push to AWS ECR
                withAWS(credentials: 'aws-sant', region: "${AWS_DEFAULT_REGION}") {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:latest"
                }
            }
        }

        stage('Update GitOps Manifest') {
            steps {
                // This stage updates the deployment.yaml with the new image tag
                withCredentials([usernamePassword(credentialsId: 'git-sant', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    script {
                        sh """
                            git config user.email "suna@rrr.com"
                            git config user.name "santanu"
                            
                            # Use 'sed' to update the image tag in deployment.yaml
                            sed -i 's|image: .*|image: ${REPOSITORY_URI}:${IMAGE_TAG}|g' k8s/deployment.yaml
                            
                            git add k8s/deployment.yaml
                            git commit -m "Update image tag to ${IMAGE_TAG} [skip ci]"
                            
                            # Push back to the repository using credentials
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/sunaofficials/MlOps-Santanu-insurance-predictor.git main
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup local images to save disk space on your t3.medium nodes
            sh "docker rmi ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG} || true"
        }
    }
}
