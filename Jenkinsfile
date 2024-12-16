pipeline {
    agent any

    stages {
        stage('Build And Push Docker Image') {
            steps {
                script {
                    try {
                     pushChatworkMessage('Start Build And Push Docker Image')
                     setup()

                     sh 'chmod +x ./build_and_push_docker_image.sh'
                     def listEcr = readJSON text: env.LIST_ECR
                     listEcr.each { user, ecr ->
                         def ecrJson = new groovy.json.JsonBuilder(ecr).toString()
                         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${user}"]]) {
                            sh """
                                   ./build_and_push_docker_image.sh '${ecrJson}' '${env.NEW_VERSION_TAG}'
                               """
                         }
                     }

                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_and_push_docker_image'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }

        // stage('Get Image to Lambda test') {
        //     when {
        //         expression {
        //             return currentBuild.result != 'FAILURE'
        //         }
        //     }
        //     steps {
        //         script {
        //             try {
        //              pushChatworkMessage('Start Get Image to Lambda test')
        //              setup()

        //              sh 'chmod +x ./get_image_to_lambda_test.sh'
        //              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_LAMBDA_CREDENTIALS}"]]) {
        //                 sh """
        //                        ./get_image_to_lambda_test.sh '${env.LAMBDA_TEST}' '${env.LIST_ECR}' '${env.NEW_VERSION_TAG}'
        //                    """
        //              }
        //             } catch (Exception e) {
        //                 currentBuild.result = 'FAILURE'
        //                 env.ERROR_STAGE = 'get_image_to_lambda_test'
        //                 env.EXCEPTION_MESSAGE = e.message
        //             }
        //         }
        //     }
        // }
        

        stage('Get Image to Lambda') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     pushChatworkMessage('Start Get Image to Lambda')
                     setup()

                     sh 'chmod +x ./get_image_to_lambda.sh'
                     def listLambdas = readJSON text: env.LIST_LAMBDAS
                     listLambdas.each { user, lambdas ->
                        def lambdasJson = new groovy.json.JsonBuilder(lambdas).toString()
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${user}"]]) {
                             sh """
                                    ./get_image_to_lambda.sh '${lambdasJson}' '${env.NEW_VERSION_TAG}' '${user}'
                                """
                        }
                      }

                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'get_image_to_lambda'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }

        stage('Build Frontend') {
            when {
                expression {
                    return currentBuild.result != 'FAILURE'
                }
            }
            steps {
                script {
                    try {
                     pushChatworkMessage('Start Build Frontend')
                     setup()

                     sh 'chmod +x ./build_frontend.sh'
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "aws-lambda"]]) {
                        sh """
                               ./build_frontend.sh '${env.NEW_VERSION_TAG}' '${env.GIT_INFO}'
                           """
                       }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        env.ERROR_STAGE = 'build_frontend'
                        env.EXCEPTION_MESSAGE = e.message
                    }
                }
            }
        }

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
    //                              def listLambdas = readJSON file: successLambdasFile
    //                              def listEcr = readJSON text: env.LIST_ECR
    //                              listLambdas.each { user, lambdas ->
    //                                 def lambdasJson = new groovy.json.JsonBuilder(lambdas).toString()
    //                                 def ecrJson = new groovy.json.JsonBuilder(listEcr["${user}"]).toString()
    //                                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${user}"]]) {
    //                                      sh """
    //                                             ./rollback_image_to_lambda.sh '${lambdasJson}' '${ecrJson}' '${env.OLD_VERSION_TAG}'
    //                                         """
    //                                 }
    //                               }

    //                             sh 'chmod +x ./build_frontend.sh'
    //                             sh """
    //                                 ./build_frontend.sh '${env.OLD_VERSION_TAG}' '${env.GIT_INFO}'
    //                             """
    //                          } catch (Exception e) {
    //                              def jsonContent = readFile(successLambdasFile)
    //                              pushChatworkMessage("[toall]\n Rollback error: ${jsonContent}")
    //                          }
    //                         break
    //                 }
    //             }

    //             // remove images
    //             sh 'chmod +x ./remove_images.sh'
    //             sh './remove_images.sh'

    //             if (currentBuild.result == 'SUCCESS') {
    //                 script {
    //                     pushChatworkMessage('Deploy success')
    //                     writeFile file: env.VERSION_FILE, text: "${env.NEW_VERSION_TAG.toInteger()}"
    //                 }
    //             }

    //             if (fileExists(successLambdasFile)) {
    //                 sh "rm ${successLambdasFile}"
    //             }
    //         }
    //     }
    // }

}


def pushChatworkMessage(String message) {
    sh 'chmod +x ./push_chatwork_message.sh'
    def body = '[toall]\n ' + message
    sh """
            ./push_chatwork_message.sh '${env.CHATWORK_CREDENTIAL}' '${body}'
        """
}


def setup() {
    def branch = scm.branches[0].name
    if (branch.contains("*/")) {
        branch = branch.split("\\*/")[1]
    }
    branch = branch.toUpperCase()

    env.LIST_ECR = env."${branch}_LIST_ECR"
    env.LIST_LAMBDAS = env."${branch}_LIST_LAMBDAS"
    def oldVersionTag = null

    if (fileExists(env.VERSION_FILE)) {
        def versionText = readFile(env.VERSION_FILE).trim()
        oldVersionTag = versionText ? versionText.toInteger() : null
    }

    if (oldVersionTag == null) {
        oldVersionTag = env."${branch}_OLD_VERSION_TAG"
        oldVersionTag = oldVersionTag ? oldVersionTag.toInteger() : 1
    }

    env.OLD_VERSION_TAG = oldVersionTag

     if(env.setup) {
        return;
     }

    def response = httpRequest(
        url: "http://localhost:8080/job/${env.JOB_NAME}/${currentBuild.number}/api/json",
        authentication: 'jenkins'
    )
    def json = readJSON text: response.content
    def causes = json.actions.find { it._class == "hudson.model.CauseAction" }?.causes
    def restartedCause = causes.find { it.shortDescription?.contains("Restarted from build") }

    env.NEW_VERSION_TAG = currentBuild.number.toInteger()
    if (restartedCause) {
        def restartedBuildId = restartedCause.shortDescription.replaceAll(/.*Restarted from build #(\d+).*/, '$1')
        env.NEW_VERSION_TAG = restartedBuildId.toInteger()
    }

    env.setup = true
}
