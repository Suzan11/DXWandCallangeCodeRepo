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
Footer
© 2022 GitHub, Inc.
