#Log in to Amazon ECR
def ecrLogin = sh(script: 'aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com', returnStdout: true).trim()
echo "Logged in to ECR"

#Push Docker image to Amazon ECR

docker push 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest