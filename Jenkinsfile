pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'flutter-news-app'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Flutter') {
            steps {
                sh '''
                    git clone https://github.com/flutter/flutter.git
                    export PATH="$PATH:`pwd`/flutter/bin"
                    flutter doctor
                    flutter config --enable-web
                '''
            }
        }
        
        stage('Flutter Build') {
            steps {
                sh '''
                    export PATH="$PATH:`pwd`/flutter/bin"
                    flutter pub get
                    flutter build web
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    export PATH="$PATH:`pwd`/flutter/bin"
                    flutter test
                '''
            }
        }
        
        stage('Docker Push') {
            when {
                branch 'main'  // Only run on main branch
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'  // Only deploy from main branch
            }
            steps {
                script {
                    // Stop existing container if running
                    sh '''
                        if docker ps -q --filter "name=${DOCKER_IMAGE}" | grep -q .; then
                            docker stop ${DOCKER_IMAGE}
                            docker rm ${DOCKER_IMAGE}
                        fi
                    '''
                    
                    // Run new container
                    sh "docker run -d -p 8080:80 --name ${DOCKER_IMAGE} ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
    }
} 