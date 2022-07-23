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


## Launch a Linux EC2 Instance and configure security group.
user AWS console to launch linux ec2 with the needed security groups, basically tcp port 8080, which will be used as port for the jenkins server
Inbound rules are:

22 [tcp] - SSH port
8080 [tcp] -  HTTP port for jenkins




## Update the installed packages
```
sudo su
yum update
```

## Install Java 8
```
java -version
yum install java-1.8.0
```

## Install Jenkins
1.) Download the latest Jenkins package from the Red Hat Repository
```
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
```
2.) Import the verification key using the package manager RPM
```
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
```


>Note: If you've previously imported the key from Jenkins, the "rpm --import" will fail because you already have a key. Please ignore that and move on.


3.) Install the Jenkins package by issuing the following command
```
yum install -y jenkins
```

## Start Jenkins Service
You can start the jenkins service by issuing the following command
```
service jenkins start
```

## Check Jenkins Installation
You can check the Jenkins process running on your server by issuing the following command 
```
ps -aux | grep jenkins
```

## Auto-Start Jenkins Service on system reboot
You can ensure that Jenkins will start following a system reboot by issuing the following command
```
chkconfig jenkins on
```

## Stop Jenkins Service
As needed, you can stop the Jenkins process by issuing the following command
```
service jenkins stop
```


# Install Jenkins on AWS EC2 Instance

## Restart Jenkins Service
You can restart the Jenkins process by issuing the following command
```
service jenkins restart
```

## Configure Jenkins
1.) Access Jenkins through browser
```
http://YOUR-SERVER-PUBLIC-IP:8080
```

2.) Now copy the default admin password and paste it to unblock the Jenkins
```
cat /var/lib/jenkins/secrets/initialAdminPassword
```

3.) Choose install suggested plugins


4.) Create your first admin user
## Install Git and AWS-CLI
you need to install latest GIT and aws-cli on the jenkins server as well.

# creating AWS IAM user.
creating AWS IAM user using the AWS console with the below needed policies which needed to run the cloudformation stack for all needed resouces:

![image](https://user-images.githubusercontent.com/3112090/162576999-2e9793a8-48db-4bb6-8f4a-e5e022b1c2d2.png)
# create github repo and configure github webhook.
create a public repo which will have all the source code, and configure the webhook to push autmoatically once any update to the source code has done:

Step 1: go to your GitHub repository and click on ‘Settings’.
Step 2: Click on Webhooks and then click on ‘Add webhook’.
![image](https://user-images.githubusercontent.com/3112090/162577906-5ac8ab51-11e6-4efc-ac78-547679b6772a.png)
Step 3: Go to your Jenkins tab and copy the URL then paste it in the text field named “Payload URL“

![image](https://user-images.githubusercontent.com/3112090/162578033-29482153-63e1-4316-a732-432ea79c4cba.png)


# Create cloudformation template
Cloudformation Template that will create the following:
  - API Gateway deployed as a REGIONAL endpoint.
  - Single root method, accepting POST requests , with Lambda proxy integration to a target function.
  - In-line Python Lambda function which that prints the request header, method, and body.
  - IAM role for Lambda allowing CloudWatch logs access.
  - Permissions for Lambda that allow API Gateway endpoint to successfully invoke function.
  - CloudWatch logs group for Lambda, with 90 day log retention.
After standing up the template, you will be able to make a HTTP  request to the URL listed as the apiGatewayInvokeURL output value.

$ curl --request POST https://APIGW_ID.execute-api.AWS_REGION.amazonaws.com/call
```
AWSTemplateFormatVersion: 2010-09-09
Description: My API Gateway and Lambda function

Parameters:
  apiGatewayName:
    Type: String
    Default: my-api
  apiGatewayStageName:
    Type: String
    AllowedPattern: "[a-z0-9]+"
    Default: call
  apiGatewayHTTPMethod:
    Type: String
    Default: POST
  lambdaFunctionName:
    Type: String
    AllowedPattern: "[a-zA-Z0-9]+[a-zA-Z0-9-]+[a-zA-Z0-9]+"
    Default: my-function

Resources:
  apiGateway:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Description: Example API Gateway
      EndpointConfiguration:
        Types:
          - REGIONAL
      Name: !Ref apiGatewayName

  apiGatewayRootMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      AuthorizationType: NONE
      HttpMethod: !Ref apiGatewayHTTPMethod
      Integration:
        IntegrationHttpMethod: POST
        Type: AWS_PROXY
        Uri: !Sub
          - arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${lambdaArn}/invocations
          - lambdaArn: !GetAtt lambdaFunction.Arn
      ResourceId: !GetAtt apiGateway.RootResourceId
      RestApiId: !Ref apiGateway

  apiGatewayDeployment:
    Type: AWS::ApiGateway::Deployment
    DependsOn:
      - apiGatewayRootMethod
    Properties:
      RestApiId: !Ref apiGateway
      StageName: !Ref apiGatewayStageName

  lambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      Code:
        ZipFile: |
          def handler(event,context):
            response_part1 = 'Welcome to our demo API, here are the details of your request: \n "***Headers***: \n {}'.format(event['headers'] ) 
            response_part2 = response_part1 + ': \n***Method***: \n {}'.format(event['httpMethod'] )
            response_part3 = response_part2 + ': \n***body***: \n {}'.format(event['body'] )
            response_part4 = response_part3 + ' \n'
            return {
             'body': response_part4,
             'headers': {
                'Content-Type': 'text/plain'
              },
              'statusCode': 200
            }
      Description: Example Lambda function
      FunctionName: !Ref lambdaFunctionName
      Handler: index.handler
      MemorySize: 128
      Role: !GetAtt lambdaIAMRole.Arn
      Runtime: python3.8

  lambdaApiGatewayInvoke:
    Type: AWS::Lambda::Permission
    Properties:
      Action: lambda:InvokeFunction
      FunctionName: !GetAtt lambdaFunction.Arn
      Principal: apigateway.amazonaws.com
      # note: if route *not* at API Gateway root, `SourceArn` would take the form of:
      #               arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${apiGateway}/${apiGatewayStageName}/${apiGatewayHTTPMethod}/PATH_PART
      SourceArn: !Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${apiGateway}/${apiGatewayStageName}/${apiGatewayHTTPMethod}/

  lambdaIAMRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Action:
              - sts:AssumeRole
            Effect: Allow
            Principal:
              Service:
                - lambda.amazonaws.com
      Policies:
        - PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Effect: Allow
                Resource:
                  - !Sub arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/${lambdaFunctionName}:*
          PolicyName: lambda

  lambdaLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /aws/lambda/${lambdaFunctionName}
      RetentionInDays: 90

Outputs:
  apiGatewayInvokeURL:
    Value: !Sub https://${apiGateway}.execute-api.${AWS::Region}.amazonaws.com/${apiGatewayStageName}

  lambdaArn:
    Value: !GetAtt lambdaFunction.Arn
    
  ``` 
 # Jenkins pipeline setup
 ## Install all needed plugins to run the cloudformation tempalte and AWS credentials with all their dependcies plugins:
   - jenkins-cloudformation-plugin
   - CloudBees AWS Credentials Plugin
   - Pipeline: AWS Steps
   
 ##  configure AWS credentials in Jenkins:

- On the Jenkins dashboard, go to Manage Jenkins > Manage Plugins in the Available tab
-  Search for the Pipeline: AWS Steps plugin and choose Install without restart.
-  Navigate to Manage Jenkins > Manage Credentials > Jenkins (global) > Global Credentials > Add Credentials.
-  Select Kind as AWS credentials and add the ID name.
-  Enter the access key ID and secret access key for the IAM user we have created above and choose OK.

  
 ## create a pipeline job which the below confg:
 
 ![image](https://user-images.githubusercontent.com/3112090/162578209-b9e6a739-7e30-4ac4-b1f2-a8c5415dd69e.png)
 
 
 
 ![image](https://user-images.githubusercontent.com/3112090/162578227-3a435b9a-c499-4b45-9c7a-33106dbbfd93.png)
 
 

![image](https://user-images.githubusercontent.com/3112090/162578248-0b8083db-330d-4800-aa25-d1d3f72ad79c.png)



![image](https://user-images.githubusercontent.com/3112090/162578260-99c90f22-6413-427c-9a08-eb0340b9f312.png)


 ## Jenkins file :
 - the jenkins file conatins three stages:
    - deploy stage, which is take care of deploying the cloudformation stack.
    - test stage, which will take care of check if the stack is created propely, and the lambda function return the expected output.
    - delete stage, this stage check the result of test stage, if test stage run successfully, the delete process will be executed and the pipline will delete the created stage.

```
  
pipeline {

    agent any 
      stages {
       stage('Create Stack') {
            steps {
                  withAWS(credentials: 'jenkinsawscred', region: 'us-east-1') {
                          sh "chmod +x -R ${env.WORKSPACE} "  
                               sh 'scripts/deploy-stack.sh'

                  }   
            }
        }
           stage('Test Stack') {
            steps {
                withAWS(credentials: 'jenkinsawscred', region: 'us-east-1') {

                   sh '   scripts/test-stack.sh'
                     script
                     {
                       
                TEST_STATUS= sh (
                             script: "scripts/test-stack.sh | grep 'sucessfully'",
                             returnStatus: true
                         ) == 0
                        echo "Build full flag: ${TEST_STATUS}"
                     }          

                }        
            }
        }
       
     stage('Delete Stack') {
            steps {
                 script
                 {
                  withAWS(credentials: 'jenkinsawscred', region: 'us-east-1') {
                            if(TEST_STATUS){
                               sh 'scripts/delete-stack.sh'
                            }
                  }
                 }
                }  
             }
   
   }
       

}
```







