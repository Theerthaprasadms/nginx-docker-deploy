pipeline {
    agent any

    environment {
        IMAGE_NAME = "nginx-custom"
        IMAGE_TAG = "${params.ENVIRONMENT ?: 'dev'}"
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Choose the environment')
    }

    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/Theerthaprasadms/nginx-docker-deploy.git'
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Test') {
            steps {
                script {
                    sh '''
                        echo "Cleaning up existing container (if any)..."
                        docker rm -f nginx-test || true

                        echo "Running container for test..."
                        docker run -d -p 8888:80 --name nginx-test ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Push to Registry') {
            when {
                expression { return params.ENVIRONMENT == 'prod' }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} $DOCKER_USER/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push $DOCKER_USER/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy on Slave') {
            steps {
                echo "Deployment logic goes here (Docker run or Kubernetes apply)..."
            }
        }

        stage('Expose IP') {
            steps {
                sh '''
                    CONTAINER_ID=$(docker ps -qf "name=nginx-test")
                    if [ -n "$CONTAINER_ID" ]; then
                        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID
                    else
                        echo "No running container found."
                    fi
                '''
            }
        }
    }
}
