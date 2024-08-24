pipeline {
    agent any

    environment {
        AWS_ECR_CREDENTIALS = 'aws-ecr'
        AWS_LAMBDA_CREDENTIALS = 'aws-lambda'
        VERSION_FILE = 'version.txt'
    }

    stages {
        stage('Get Current Version') {
            steps {
                script {
                    if (fileExists(VERSION_FILE)) {
                        def versionText = readFile(VERSION_FILE).trim()
                        def version = versionText.isInteger() ? versionText.toInteger() : 1
                        env.CURRENT_VERSION = version
                    } else {
                        env.CURRENT_VERSION = 1
                    }
                    env.NEW_VERSION_TAG = "v${env.CURRENT_VERSION.toInteger() + 1}"
                }
            }
        }

        stage('Build And Push Docker Image') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     sh 'chmod +x ./build_and_push_docker_image.sh'
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_ECR_CREDENTIALS}"]]) {
                        sh """
                               ./build_and_push_docker_image.sh "${env.ECR_INFO}" "${env.NEW_VERSION_TAG}"
                           """
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'build_and_push_docker_image'
                    }
                }
            }
        }

        stage('Get Image to Lambda') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     sh 'chmod +x ./get_image_to_lambda.sh'
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
                        sh """
                               ./get_image_to_lambda.sh "${env.LIST_LAMBDAS}" "${env.ECR_INFO}" "${env.NEW_VERSION_TAG}"
                           """
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        currentBuild.description = 'get_image_to_lambda'
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (currentBuild.result == 'FAILURE') {
                    sh 'chmod +x ./push_chatwork_message.sh'
                    def body = 'Error stage ' + currentBuild.description
                    sh """
                           ./push_chatwork_message.sh "${env.CHATWORK_CREDENTIAL}" "${body}"
                       """
//                     switch (currentBuild.description) {
//                         case 'build_and_push_docker_image':
//                             echo "Running rollback for build_and_push_docker_image..."
//                             break
//                         case 'get_image_to_lambda':
//                             echo "Running rollback for get_image_to_lambda..."
//                             break
//                     }
                } else {
                    script {
                        writeFile file: VERSION_FILE, text: "${env.CURRENT_VERSION.toInteger() + 1}"
                    }
                }
            }
        }
    }

}
