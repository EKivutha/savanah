pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'your-image-name'
        DOCKER_TAG = "${GIT_COMMIT}"  // Tagging image with the Git commit hash
        DOCKER_REGISTRY = 'docker.io'  // Docker Hub registry URL
        DOCKER_REPO = 'yourusername/your-repo'  // Docker Hub repository
        AWS_REGION = 'us-east-1'  // AWS region
        AWS_ECR_REPO = 'your-ecr-repo'  // ECR repository name
        ECS_CLUSTER = 'your-ecs-cluster'
        ECS_SERVICE = 'your-ecs-service'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    // Docker login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    }
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag the Docker image with the latest tag
                    sh "docker tag ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REGISTRY}/${DOCKER_REPO}:latest"
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_REPO}:latest"
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    // Login to AWS ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                }
            }
        }

        stage('Tag Docker Image for ECR') {
            steps {
                script {
                    // Tag the Docker image for ECR
                    sh "docker tag ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_REPO}:${DOCKER_TAG}"
                }
            }
        }

        stage('Push Docker Image to AWS ECR') {
            steps {
                script {
                    // Push the Docker image to AWS ECR
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_REPO}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to AWS ECS') {
            steps {
                script {
                    // Update ECS service with the new task definition
                    sh """
                    ecs-cli configure --cluster ${ECS_CLUSTER} --region ${AWS_REGION}
                    ecs-cli compose --file docker-compose.yml up
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed!'
        }
    }
}
