#!/bin/bash

echo " In deploy stack stage now ................."
echo " Test is passed and we're going to clean the stack"

aws cloudformation validate-template --template-body file://DXwandstack.yml 
 aws cloudformation deploy \
 --stack-name DXwandstack  \
 --template-file DXwandstack.yml \
 --capabilities CAPABILITY_NAMED_IAM 
