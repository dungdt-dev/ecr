pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-ecr' // ID của credentials trong Jenkins
    }

    stages {
        stage('Clone Code') {
            steps {
                // Clone mã nguồn từ repository
                git 'https://github.com/dungdt-dev/ecr.git' // Thay thế bằng URL của repository của bạn
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Đăng nhập vào Amazon ECR
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        def ecrLogin = sh(script: 'aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com', returnStdout: true).trim()
                        echo "Logged in to ECR"
                    }

                    // Build Docker image
                    sh 'docker build -t demo .'
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag Docker image
                    sh 'docker tag demo:latest 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest'
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    // Push Docker image to Amazon ECR
                    sh 'docker push 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest'
                }
            }
        }

        stage('Lambda pull image') {
                    steps {
                        script {
                         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                                def ecrLogin = sh(script: 'aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com', returnStdout: true).trim()
                                echo "Logged in to ECR"
                                 sh 'aws lambda update-function-code \
                                      --function-name demo-lambda \
                                      --image-uri 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest'
                            }
                        }
                    }
                }
    }
}
