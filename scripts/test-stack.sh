echo " We're in the test Stage .........................................................."
stack_status=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE | grep "CREATE_COMPLETE")
apiID=$(aws apigateway get-rest-apis | grep "id" | head -1 | cut -d':' -f 2 | cut -d'"' -f 2)
url="https://$apiID.execute-api.us-east-1.amazonaws.com/call"
echo "We will run this URL to test the lambda function: $url  and the output is:"
curl --header "Content-Type: application/json" --data '{"username":"xyz","password":"xyz"}' $url 2>/dev/null
lambda_status=$(curl --header "Content-Type: application/json" --data '{"username":"xyz","password":"xyz"}' $url 2>/dev/null | grep "body")

if [[ -n $stack_status && -n $lambda_status ]]; then
   echo "Stack is created sucessfully and lambda function is tested successfully."
else
   echo "Seems there's an issue happened while testing, Please check the logs for mor info."
