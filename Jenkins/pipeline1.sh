pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}

--------------------
Multi Steps:-

steps {
    sh ```
        echo chirag
        echo rathi
        echo tarighat
    ```
}

---------------------------
Retry :-
if provide no of retry then try to run 

retry(3) {
    sh 'echo chirag'
}

Note:- If any case this command is not working so try to max 3 time and this retry method store inside steps bresess.

-----------------------------
Time :-
 This is also inside steps bresess

 timeout(time:5, unit:'SECONDS') {
    sh 'sleep 30'
 }

 If timeout bress we don't provide 5 then that steps wait 30 sec, but if define time:5 means after 5 sec this task done.

 ------------------------------------
 Environment define below agent :-

 environment{
    NAME="Chirag Rathi"
    AGE=30
 }

 and we use this environment value in our steps command

 If we need to store the password so we not directly added
 flow

 Manage Jenkins -> Security -> Credentials -> System -> Global -> 

 Pass=credentails.('key')  #key we are added in credentails side 