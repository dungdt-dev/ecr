pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/dungdt-dev/ecr.git'
            }
        }

        stage('Build image') {
            steps {
                withDockerRegistry(credentialsId: 'ecr:ap-southeast-1:aws-ecr', url: '022499014177.dkr.ecr.ap-southeast-1.amazonaws.com') {
                   sh 'aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com'
                   sh 'docker build -t demo .'
                   sh 'docker push 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest'
                }
            }
        }
    }
}