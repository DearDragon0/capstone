pipeline {
    agent any

    environment {
        MAVEN_HOME = tool 'maven'
        DOCKER_HUB_USER = 'deardragon'
        IMAGE_NAME = 'insure-me'
        IMAGE_TAG = '3.0'
        HTTP_PORT = '8081'
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend with Maven') {
            steps {
                sh "${MAVEN_HOME}/bin/mvn clean package"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Scan Docker Image') {
            steps {
                echo 'Scanning Docker image (you can integrate Trivy here)'
                // Example: sh "trivy image ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                sh '''
                    docker rm -f ${IMAGE_NAME} || true
                    docker pull ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker run -d --rm -p ${HTTP_PORT}:${HTTP_PORT} --name ${IMAGE_NAME} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
                echo "Application deployed at http://localhost:${HTTP_PORT}"
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
