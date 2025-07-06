node {
    def mavenHome, mavenCMD, tag = "3.0", dockerHubUser = "deardragon", containerName = "insure-me", httpPort = "8081"

    stage('Prepare Environment') {
        echo 'Initializing Environment'
        mavenHome = tool name: 'maven', type: 'hudson.tasks.Maven$MavenInstallation'
        mavenCMD = "${mavenHome}/bin/mvn"
    }

    stage('Code Checkout') {
        try {
            checkout scm
        } catch (Exception e) {
            echo 'Exception occurred in Git Checkout Stage: ' + e.getMessage()
            currentBuild.result = "FAILURE"
            // Optional: Add email alert here
            error("Stopping pipeline due to checkout failure.")
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
            reportName: 'HTML Report',
            useWrapperFileDirectly: true
        ])
    }

    stage('Docker Image Build') {
        echo 'Building Docker Image'
        sh "docker build -t ${dockerHubUser}/${containerName}:${tag} --pull --no-cache ."
    }

    stage('Docker Image Scan') {
        echo 'Scanning Docker image (placeholder - you can add Trivy or other tools here)'
        // Example scan command:
        // sh "trivy image ${dockerHubUser}/${containerName}:${tag}"
    }

    stage('Publishing Image to DockerHub') {
        echo 'Pushing Docker image to DockerHub'
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'dockerUser', passwordVariable: 'dockerPassword')]) {
            sh "docker login -u ${dockerUser} -p ${dockerPassword}"
            sh "docker push ${dockerHubUser}/${containerName}:${tag}"
            echo "Image push complete"
        }
    }

    stage('Docker Container Deployment') {
        sh "docker rm ${containerName} -f || true"
        sh "docker pull ${dockerHubUser}/${containerName}:${tag}"
        sh "docker run -d --rm -p ${httpPort}:${httpPort} --name ${containerName} ${dockerHubUser}/${containerName}:${tag}"
        echo "Application deployed on port ${httpPort}"
    }
}
