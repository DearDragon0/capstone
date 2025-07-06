node {
    def mavenHome, mavenCMD, dockerHubUser, tag, containerName, httpPort

    stage('Prepare Environment') {
        echo 'Initialize Environment'
        mavenHome = tool name: 'maven 3.6.3', type: 'maven'
        mavenCMD = "${mavenHome}/bin/mvn"
        tag = "3.0"
        dockerHubUser = "deardragon"
        containerName = "insure-me"
        httpPort = "8081"
    }

    stage('Code Checkout') {
        try {
            checkout scm
        } catch (Exception e) {
            echo 'Exception occurred in Git Code Checkout Stage'
            currentBuild.result = "FAILURE"
        }
    }

    stage('Maven Build') {
        sh "${mavenCMD} clean package"
    }

    stage('Publish Test Reports') {
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: false,
            reportDir: 'target/surefire-reports',
            reportFiles: 'index.html',
            reportName: 'HTML Report'
        ])
    }

    stage('Docker Image Build') {
        echo 'Creating Docker image'
        sh "docker build -t $dockerHubUser/$containerName:$tag --pull --no-cache ."
    }

    stage('Docker Image Scan') {
        echo 'Scanning Docker image for vulnerabilities'
        echo 'Docker scan placeholder (add actual scan tool here)'
    }

    stage('Push Docker Image to DockerHub') {
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker push $dockerHubUser/$containerName:$tag
            """
        }
    }

    stage('Docker Container Deployment') {
        sh "docker rm $containerName -f || true"
        sh "docker pull $dockerHubUser/$containerName:$tag"
        sh "docker run -d --rm -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
        echo "Application started on port: ${httpPort} (http)"
    }
}
