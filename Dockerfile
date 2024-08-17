FROM public.ecr.aws/lambda/nodejs:20

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

RUN npm install
  
# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "index.handler" ]