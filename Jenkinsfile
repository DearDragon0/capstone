node {
    def mavenHome, mavenCMD, dockerHubUser, tag, containerName, httpPort

    stage('Prepare Environment') {
        echo 'Initialize Environment'
        mavenHome = tool name: 'maven', type: 'maven'
        mavenCMD = "${mavenHome}/bin/mvn"
        tag = "3.0"
        dockerHubUser = "anujsharma1990"
        containerName = "insure-me"
        httpPort = "8081"
    }

    stage('Code Checkout') {
        try {
            checkout scm
        } catch (Exception e) {
            echo 'Exception occurred in Git Code Checkout Stage'
            currentBuild.result = "FAILURE"
            // Uncomment and configure the following lines for email notifications if needed.
            // emailext body: """Dear All,
            // The Jenkins job ${JOB_NAME} has failed. Please check it immediately by clicking the link below.
            // ${BUILD_URL}""", subject: "Job ${JOB_NAME} ${BUILD_NUMBER} has failed", to: "jenkins@gmail.com"
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
        // Ideally, use a security scanning tool here (e.g., Trivy, Anchore)
        // For now, this is just a placeholder; remove redundant docker build:
        // sh "docker build -t ${dockerHubUser}/insure-me:${tag} ."
        echo 'Docker scan placeholder (add actual scan tool here)'
    }

    stage('Publishing Image to DockerHub') {
        echo 'Pushing the docker image to DockerHub'
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'dockerHubUser', passwordVariable: 'dockerPassword')]) {
            sh "docker login -u $dockerHubUser -p $dockerPassword"
            sh "docker push $dockerUser/$containerName:$tag"
            echo "Image push complete"
        }
    }

    stage('Docker Container Deployment') {
        sh "docker rm $containerName -f || true"
        sh "docker pull $dockerHubUser/$containerName:$tag"
        sh "docker run -d --rm -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
        echo "Application started on port: ${httpPort} (http)"
    }
}
