node{
    
    def mavenHome, mavenCMD, docker, tag, dockerHubUser, containerName, httpPort = ""
    
    stage('Prepare Environment'){
        echo 'Initialize Environment'
        mavenHome = tool name: 'maven' , type: 'maven'
        mavenCMD = "${mavenHome}/bin/mvn"
        tag="3.0"
	dockerHubUser="deardragon"
	containerName="insure-me"
	httpPort="8081"
    }
    
    stage('Code Checkout'){
        try{
            checkout scm
        }
        catch(Exception e){
            echo 'Exception occured in Git Code Checkout Stage'
            currentBuild.result = "FAILURE"
            //emailext body: '''Dear All,
            //The Jenkins job ${JOB_NAME} has been failed. Request you to please have a look at it immediately by clicking on the below link. 
            //${BUILD_URL}''', subject: 'Job ${JOB_NAME} ${BUILD_NUMBER} is failed', to: 'hcpro2017@gmail.com'
        }
    }
    
    stage('Maven Build'){
        sh "${mavenCMD} clean package"        
    }
    
    stage('Publish Test Reports'){
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
    }
    
    stage('Docker Image Build'){
        echo 'Creating Docker image'
        sh "docker build -t deardragon/insure-me:$tag --pull --no-cache ."
    }
	
    stage('Docker Image Scan'){
        echo 'Scanning Docker image for vulnerbilities'
        sh "docker build -t deardragon/insure-me:${tag} ."
    }   
	
    stage('Publishing Image to DockerHub'){
        echo 'Pushing the docker image to DockerHub'
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'dockerUser', passwordVariable: 'dockerPassword')]) {
			sh "docker login -u deardragon -p Look@1234"
			sh "docker push deardragon/insure-me:$tag"
			echo "Image push complete"
        } 
    }    
	
	stage('Docker Container Deployment'){
		sh "docker rm insure-me -f"
		sh "docker pull deardragon/insure-me:$tag"
		sh "docker run -d --rm -p 8081:8081 --name insure-me deardragon/insure-me:$tag"
		echo "Application started on port: ${httpPort} (http)"
	}
}



