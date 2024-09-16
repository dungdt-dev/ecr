FROM public.ecr.aws/lambda/nodejs:20

# Install Git
RUN dnf install -y git

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}
# install git + config ssh key +

RUN npm install
# build node (ts) -> build frontend
  
# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "index.handler" ]