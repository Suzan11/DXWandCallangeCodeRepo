# DXWandCallangeCodeRepo


Setup Jenkins CICD Pipeline for AWS Lambda with GitHub and Cloudformation Template:

Lambda function is written in Python. Then it will push the code to the version control system. Here in our case, we are taking GitHub as our version control system.

Along with this, here we are adding cloudformation Template to define the architecture of the serverless application. 

So, Our Jenkins Job will be triggered by GitHub whenever we push the code into GitHub Repo. Then, building it with the specified build information of the applications from cloudformation Template file.

This jenkins job is configured that whenever we push any update on the Lambda function or the cloudformation template file, this pipeline will automatically get triggered and the entire workflow will be executed and finally it will automatically be deployed again to the AWS platform.

- Let’s Prepare for the Setup. So, To set up the complete workflow, we need to do the following actions:
  - create EC2 which will host Jenkins server.
  - creating AWS IAM user.
  - create github repo and configure github webhook.
  - Create cloudformation template.
  - Jenkins Pipeline setup


# Install Jenkins on AWS EC2 Instance





