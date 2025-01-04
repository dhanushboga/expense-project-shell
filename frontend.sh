#!/bin/bash

LOG_FOLDER="/var/log/frontend-logs"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%m-%s)
LOG_FILE_NAME=$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
if [ $1 -ne 0 ]
   then
     echo -e "$2............$R FAILURE $N"
   else
     echo -e "$2............$G SUCCESS $N"
fi
}

CHECK_ROOT(){
    if [ $USER_ID -ne 0 ]
    then
      echo -e $R "ERROR::Please run this Script under root access" $N
      exit 1
    fi
}

echo "The $0 Script run at :$TIME_STAMP"

mkdir -p $LOG_FOLDER
VALIDATE $? "Creating the logs folder for Frond-End server"

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the Nginx Server"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling the Nginx Server"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting the Nginx Server"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing the existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading the Web server code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Changing the directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping the Frond-end code"

cp /home/ec2-user/expense-project-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "Coping the content to conf file"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting the Nginx Server"








