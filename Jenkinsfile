pipeline {
    agent any

    environment {
        AWS_ECR_CREDENTIALS = 'aws-ecr'
        AWS_LAMBDA_CREDENTIALS = 'aws-lambda'
        VERSION_FILE = 'version.txt'
    }

    stages {
        stage('Build And Push Docker Image') {
            steps {
                script {
                    try {
                    //  pushChatworkMessage('Start Build And Push Docker Image')
                    //  getVersionTags(VERSION_FILE)

                    //  sh 'chmod +x ./build_and_push_docker_image.sh'
                    //  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_ECR_CREDENTIALS}"]]) {
                    //     sh """
                    //            ./build_and_push_docker_image.sh '${env.LIST_ECR}' '${env.NEW_VERSION_TAG}'
                    //        """
                    //  }

                   getEnvForBranch()
                    
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_and_push_docker_image'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }

        // stage('Get Image to Lambda') {
        //     when {
        //         expression {
        //             return currentBuild.result != 'FAILURE'
        //         }
        //     }
        //     steps {
        //         script {
        //             try {
        //              pushChatworkMessage('Start Get Image to Lambda')
        //              getVersionTags(VERSION_FILE)

        //              sh 'chmod +x ./get_image_to_lambda.sh'
        //              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
        //                 sh """
        //                        ./get_image_to_lambda.sh '${env.LIST_LAMBDAS}' '${env.LIST_ECR}' '${env.NEW_VERSION_TAG}'
        //                    """
        //              }
        //             } catch (Exception e) {
        //                 currentBuild.result = 'FAILURE'
        //                 env.ERROR_STAGE = 'get_image_to_lambda'
        //                 env.EXCEPTION_MESSAGE = e.message
        //             }
        //         }
        //     }
        // }

        // stage('Build Frontend') {
        //     when {
        //         expression {
        //             return currentBuild.result != 'FAILURE'
        //         }
        //     }
        //     steps {
        //         script {
        //             try {
        //              pushChatworkMessage('Start Build Frontend')
        //              getVersionTags(VERSION_FILE)

        //              sh 'chmod +x ./build_frontend.sh'
        //                 sh """
        //                        ./build_frontend.sh '${env.NEW_VERSION_TAG}' '${env.GIT_INFO}'
        //                    """
        //             } catch (Exception e) {
        //                 currentBuild.result = 'FAILURE'
        //                 env.ERROR_STAGE = 'build_frontend'
        //                 env.EXCEPTION_MESSAGE = e.message
        //             }
        //         }
        //     }
        // }

    }

    // post {
    //     always {
    //         script {
    //             def successLambdasFile = 'success_lambdas.json'
    //             if (currentBuild.result == 'FAILURE') {
    //                 pushChatworkMessage('Error in stage ' + env.ERROR_STAGE + ': ' + env.EXCEPTION_MESSAGE)

    //                 switch (env.ERROR_STAGE) {
    //                     case 'get_image_to_lambda':
    //                         sh 'chmod +x ./rollback_image_to_lambda.sh'
    //                         try {
    //                              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
    //                                 sh """
    //                                        ./rollback_image_to_lambda.sh '${env.LIST_ECR}' '${env.OLD_VERSION_TAG}'
    //                                    """
    //                              }
    //                          } catch (Exception e) {
    //                              def jsonContent = readFile(successLambdasFile)
    //                              pushChatworkMessage("[toall]\n Rollback error: ${jsonContent}")
    //                          }
    //                         break
    //                 }
    //             } else {
    //                 script {
    //                     pushChatworkMessage('Deploy success')
    //                     writeFile file: VERSION_FILE, text: "${env.CURRENT_VERSION.toInteger() + 1}"
    //                 }
    //             }

    //             if (fileExists(successLambdasFile)) {
    //                 sh "rm ${successLambdasFile}"
    //             }
    //         }
    //     }
    // }

}


def getVersionTags(String versionFile) {
    if (fileExists(versionFile)) {
        def versionText = readFile(versionFile).trim()
        def version = versionText.isInteger() ? versionText.toInteger() : 0
        env.CURRENT_VERSION = version
    } else {
        env.CURRENT_VERSION = 0
    }

    env.NEW_VERSION_TAG = "v${env.CURRENT_VERSION.toInteger() + 1}"
    env.OLD_VERSION_TAG = "v${env.CURRENT_VERSION.toInteger()}"
}

def pushChatworkMessage(String message) {
    sh 'chmod +x ./push_chatwork_message.sh'
    def body = '[toall]\n ' + message
    sh """
            ./push_chatwork_message.sh '${env.CHATWORK_CREDENTIAL}' '${body}'
        """
}


def getEnvForBranch() {
    def branch = scm.branches[0].name
    if (branch.contains("*/")) {
        branch = branch.split("\\*/")[1]
        }

    env.LIST_ECR = env."${branch}_LIST_ECR"

    echo env.LIST_ECR
}
