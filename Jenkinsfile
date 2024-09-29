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
                        /* sh """
                               ./build_and_push_docker_image.sh '${env.ECR_INFO}' '${env.NEW_VERSION_TAG}'
                           """ */
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
                        /* sh """
                               ./get_image_to_lambda.sh '${env.LIST_LAMBDAS}' '${env.ECR_INFO}' '${env.NEW_VERSION_TAG}'
                           """ */
                     }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'get_image_to_lambda'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }


        /* stage(' ') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     sh 'chmod +x ./build_docker_image.sh'
                      sh """
                            ./build_docker_image.sh '${env.ECR_INFO}' '${env.NEW_VERSION_TAG}'
                        """
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_docker_image'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        } */

        stage('Build Frontend') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     sh 'chmod +x ./build_frontend.sh'
                        sh """
                               ./build_frontend.sh '${env.ECR_INFO}' '${env.NEW_VERSION_TAG}' '${env.GIT_INFO}'
                           """
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_frontend'
                        env.EXCEPTION_MESSAGE = e.message
                        /* def imageName = sh(script: 'echo "${ECR_INFO}" | jq -r \'.name\'', returnStdout: true).trim()
                        sh "docker rm -f ${imageName}"

                        def fullImageName = "${imageName}:${env.NEW_VERSION_TAG}"
                        sh "docker rmi ${fullImageName}" */
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
                            sh 'chmod +x ./rollback_image_to_lambda.sh'
                            try {
                                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
                                    sh """
                                           ./rollback_image_to_lambda.sh '${env.ECR_INFO}' '${env.OLD_VERSION_TAG}'
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

                 // Kiểm tra nếu image tồn tại và xóa image với tag cụ thể
                 def imageName = sh(script: 'echo "${ECR_INFO}" | jq -r \'.name\'', returnStdout: true).trim()
                 def imageVersion = "v${env.CURRENT_VERSION.toInteger() - 1}"
                 def fullImageName = "${imageName}:${imageVersion}"

                 def isImageExist = sh(script: "docker images -q ${fullImageName}", returnStdout: true).trim()
                 if (isImageExist) {
                     echo "Image with tag ${fullImageName} exists. Removing image..."
                     sh "docker rmi ${fullImageName}"
                 }

                 def imageTag = sh(script: 'echo "${ECR_INFO}" | jq -r \'.ecr_uri\'', returnStdout: true).trim()
                 def fullImageTag = "${imageTag}/${imageName}:${imageVersion}"
                 def isImageTagExist = sh(script: "docker images -q ${fullImageTag}", returnStdout: true).trim()
                  if (isImageTagExist) {
                      echo "Image with tag ${isImageTagExist} exists. Removing image..."
                      sh "docker rmi ${isImageTagExist}"
                  }
            }
        }
    }

}
