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
                     sh "./clone_code1.sh"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'clone_code'
                    }
                }
            }
        }

//         stage('Build And Push Docker Image') {
//             steps {
//                 script {
//                     try {
//                      sh 'chmod +x ./build_and_push_docker_image.sh'
//                      withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_ECR_CREDENTIALS}"]]) {
//                         sh './build_and_push_docker_image.sh'
//                      }
//                     } catch (Exception e) {
//                         currentBuild.result = 'FAILURE'
//                         currentBuild.description = 'build_and_push_docker_image'
//                     }
//                 }
//             }
//         }
//
//         stage('Get Image to Lambda') {
//             steps {
//                 script {
//                     try {
//                      sh 'chmod +x ./get_image_to_lambda.sh'
//                      withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
//                         sh './get_image_to_lambda.sh'
//                      }
//                     } catch (Exception e) {
//                         currentBuild.result = 'FAILURE'
//                         currentBuild.description = 'get_image_to_lambda'
//                     }
//                 }
//             }
//         }
    }

    post {
        always {
            script {
                if (currentBuild.result == 'FAILURE') {
                    sh 'chmod +x ./push_chatwork_message.sh'
                    def body = 'Error stage ' + currentBuild.description
                    sh """
                           ./push_chatwork_message.sh "${env.CHATWORK_API_TOKEN}" "${env.CHATWORK_ROOM_ID}" "${body}"
                       """
//                     switch (currentBuild.description) {
//                         case 'clone_code':
//                             echo "Running rollback for clone_code..."
//                             break
//                         case 'build_and_push_docker_image':
//                             echo "Running rollback for build_and_push_docker_image..."
//                             break
//                         case 'get_image_to_lambda':
//                             echo "Running rollback for get_image_to_lambda..."
//                             break
//                     }
                }
            }
        }
    }

}
