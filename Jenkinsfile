pipeline {
    agent any

    environment {
        MAVEN_CMD = '/usr/local/maven/bin/mvn'
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
                sh "${MAVEN_CMD} clean package"
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }
