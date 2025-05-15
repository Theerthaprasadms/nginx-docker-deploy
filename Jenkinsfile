pipeline {
    agent any
    parameters {
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Deployment Environment')
    }
    environment {
        IMAGE_NAME = "nginx-custom:${params.ENV}"
        DOCKER_REGISTRY = "docker.io/theerthaprasadms"
    }
    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/Theerthaprasadms/nginx-docker-deploy.git'
            }
        }
        stage('Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }
        stage('Test') {
            steps {
                script {
                    sh "docker run -d -p 8080:80 --name nginx-test ${IMAGE_NAME}"
                    sleep 5
                    sh '''
                    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
                    if [ "$status" -ne 200 ]; then
                        echo "Health check failed"
                        exit 1
                    fi
                    docker stop nginx-test && docker rm nginx-test
                    '''
                }
            }
        }
        stage('Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker tag ${IMAGE_NAME} ${DOCKER_REGISTRY}/${IMAGE_NAME}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}"
                }
            }
        }
        stage('Deploy on Slave') {
            steps {
                sh "docker run -d -p 8080:80 --name deployed-nginx ${DOCKER_REGISTRY}/${IMAGE_NAME}"
            }
        }
        stage('Expose IP') {
            steps {
                script {
                    def ip = sh(script: "hostname -I | awk '{print \$1}'", returnStdout: true).trim()
                    echo "Application is available at: http://${ip}:8080"
                }
            }
        }
    }
}

