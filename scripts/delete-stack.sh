echo " In delete stack stage now ................."
echo " Test is passed and we're going to clean the stack"

  aws cloudformation validate-template --template-body file://DXwandstack.yml 
  aws cloudformation  delete-stack \
    --stack-name DXwandstack
   echo " Sleeping 5 minutes untill stack is fully deleted..........."
   sleep 5m
  stack_status=$(aws cloudformation describe-stacks --stack-name DXwandstack 2>/dev/null)
 if [ -z "$stack_status" ]
 then
   echo "Stack is deleted sucessfully ."
else
   echo "Seems there's an issue happened while deleting the stack, Please check the logs for mor info."

fi

