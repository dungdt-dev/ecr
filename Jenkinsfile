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
                        def version = versionText.isInteger() ? versionText.toInteger() : 0
                        env.CURRENT_VERSION = version
                    } else {
                        env.CURRENT_VERSION = 0
                    }
                    env.NEW_VERSION_TAG = "v${env.CURRENT_VERSION.toInteger() + 1}"
                    env.OLD_VERSION_TAG = "v${env.CURRENT_VERSION.toInteger()}"
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
                               ./build_and_push_docker_image.sh '${env.ECR_INFO}' '${env.NEW_VERSION_TAG}'
                           """
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_and_push_docker_image'
                        env.EXCEPTION_MESSAGE = e.message
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
                               ./get_image_to_lambda.sh '${env.LIST_LAMBDAS}' '${env.ECR_INFO}' '${env.OLD_VERSION_TAG}'
                           """
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'get_image_to_lambda'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                def successLambdasFile = 'success_lambdas.json'
                if (currentBuild.result == 'FAILURE') {
                    sh 'chmod +x ./push_chatwork_message.sh'
                    def body = '[toall]\n Error in stage ' + env.ERROR_STAGE + ': ' + env.EXCEPTION_MESSAGE
                    sh """
                           ./push_chatwork_message.sh '${env.CHATWORK_CREDENTIAL}' '${body}'
                       """
                    switch (env.ERROR_STAGE) {
                        case 'get_image_to_lambda':
                            sh 'chmod +x ./get_image_to_lambda.sh'
                            try {
                                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
                                    sh """
                                           ./get_image_to_lambda.sh ${env.ECR_INFO}' '${env.OLD_VERSION_TAG}'
                                       """
                                 }
                             } catch (Exception e) {
                                 def jsonContent = readFile(successLambdasFile)

                                 // Xây dựng nội dung body với JSON data
                                 def bodyMessageRollback = "[toall]\n Rollback error: ${jsonContent}"
                                 sh """
                                        ./push_chatwork_message.sh '${env.CHATWORK_CREDENTIAL}' '${bodyMessageRollback}'
                                    """
                             }
                            break
                    }
                } else {
                    script {
                        writeFile file: VERSION_FILE, text: "${env.CURRENT_VERSION.toInteger() + 1}"
                    }
                }

                if (fileExists(successLambdasFile)) {
                    sh "rm ${successLambdasFile}"
                }

            }
        }
    }

}
