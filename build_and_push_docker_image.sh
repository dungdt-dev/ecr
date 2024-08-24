NEW_VERSION_TAG="$1"

#build
docker build -t demo:${NEW_VERSION_TAG} .

#Set tag
docker tag demo:${NEW_VERSION_TAG} 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:${NEW_VERSION_TAG}

#Log in to Amazon ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com

#Push Docker image to Amazon ECR
docker push 022499014177.dkr.ecr.ap-southeast-1.amazonaws.com/demo:${NEW_VERSION_TAG}