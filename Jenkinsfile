pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = 'ap-southeast-1'  // Replace with your AWS region
        ECR_REPOSITORY = 'demo'  // Replace with your ECR repository name
        IMAGE_TAG = 'latest'  // Replace with your desired image tag
    }
    stages {
        stage('Login to AWS ECR') {
            steps {
                script {
                    // Retrieve the login command from ECR and execute it directly
                    sh '''
                    $(aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com)
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh '''
                    docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
                    '''
                }
            }
        }
        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag the image with the full ECR repository URI
                    sh '''
                    docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
                    '''
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    // Push the Docker image to ECR
                    sh '''
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
                    '''
                }
            }
        }
    }
}
