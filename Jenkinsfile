pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-ecr' // ID của credentials trong Jenkins
    }

    stages {
        stage('Clone Code') {
            steps {
                sh 'chmod +x ./clone_code.sh'
                sh './clone_code.sh'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'chmod +x ./build_docker_image.sh'
                    sh './build_docker_image.sh'
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag Docker image
                    sh 'chmod +x ./set_tag_docker_image.sh'
                    sh './set_tag_docker_image.sh'
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                 sh 'chmod +x ./push_image_to_ecr.sh'
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                         sh './push_image_to_ecr.sh'
                    }
                }
            }
        }

        stage('Get Image to Lambda') {
            steps {
                script {
                    sh 'chmod +x ./get_image_to_lambda.sh'
                    sh './get_image_to_lambda.sh'
                }
            }
        }
    }
}
