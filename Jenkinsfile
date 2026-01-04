pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '814820107207'
        AWS_DEFAULT_REGION = 'ap-south-2'
        IMAGE_REPO_NAME = 'insurance-app'
        IMAGE_TAG = "v${BUILD_NUMBER}" 
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-sant', url: 'https://github.com/sunaofficials/MlOps-Santanu-insurance-predictor.git'
            }
        }

        stage('Validate Artifacts') {
            steps {
                script {
                    // Critical check: Ensure the model exists in the app folder before building
                    def modelExists = sh(script: "test -f app/model.pkl", returnStatus: true) == 0
                    if (!modelExists) {
                        error "ABORTING: model.pkl not found in app/ directory. Run training locally first!"
                    }
                    echo "Success: model.pkl found."
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build using the app directory as context
                    sh "docker build -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} ./app"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-sant', region: "${AWS_DEFAULT_REGION}") {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:latest"
                }
            }
        }

        stage('Update GitOps Manifest') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'git-sant', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    script {
                        sh """
                            git config user.email "sss@ss.com"
                            git config user.name "santanu"
                            sed -i 's|image: .*|image: ${REPOSITORY_URI}:${IMAGE_TAG}|g' k8s/deployment.yaml
                            git add k8s/deployment.yaml
                            git commit -m "Update image tag to ${IMAGE_TAG} [skip ci]"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/sunaofficials/MlOps-Santanu-insurance-predictor.git main
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG} || true"
        }
    }
}
