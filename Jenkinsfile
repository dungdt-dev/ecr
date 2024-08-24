pipeline {
    agent any

    environment {
        AWS_ECR_CREDENTIALS = 'aws-ecr'
        AWS_LAMBDA_CREDENTIALS = 'aws-lambda'
    }

    stages {
        stage('Clone Code') {
            steps {
            script {
                    try {
                     sh 'chmod +x ./clone_code.sh'
                     sh "./clone_code.sh ${env.AWS_ACCESS_KEY_ID}"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'clone_code'
                    }
                }
            }
        }

        /* stage('Build And Push Docker Image') {
            steps {
                script {
                    try {
                     sh 'chmod +x ./build_and_push_docker_image.sh'
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_ECR_CREDENTIALS}"]]) {
                        sh './build_and_push_docker_image.sh'
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'build_and_push_docker_image'
                    }
                }
            }
        }*/

        /* stage('Get Image to Lambda') {
            steps {
                script {
                    try {
                     sh 'chmod +x ./get_image_to_lambda.sh'
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
                        sh './get_image_to_lambda.sh'
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'get_image_to_lambda'
                    }
                }
            }
        } */
    }

   /*  post {
        always {
            script {
                if (currentBuild.result == 'FAILURE') {
                    switch (currentBuild.description) {
                        case 'clone_code':
                            echo "Running rollback for clone_code..."
//                             sh './rollback_deploy.sh'
                            break
                        case 'build_and_push_docker_image':
                            echo "Running rollback for build_and_push_docker_image..."
//                             sh './rollback_deploy1.sh'
                            break
                        case 'get_image_to_lambda':
                            echo "Running rollback for get_image_to_lambda..."
//                             sh './rollback_deploy1.sh'
                            break
                    }
                }
            }
        }
    } */

}
