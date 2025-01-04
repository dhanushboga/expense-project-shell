#!/bin/bash

LOG_FOLDER="/var/log/backend-logs"
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

mkdir -p $LOG_FOLDER
VALIDATE $? "Creating Logs Folder for Back-End Server"

echo "The $0 Script run at :$TIME_STAMP" &>>$LOG_FILE_NAME

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling the nodeJS Older version"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling the nodeJS New version"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the NodeJs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
   useradd expense &>>$LOG_FILE_NAME
   VALIDATE $? "Adding the expense user"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating the New Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading the NodeJS Code"

cd /app &>>$LOG_FILE_NAME
VALIDATE $? "Change directory"

rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping the Code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing the Dependencies related to code"

cp /home/ec2-user/expense-project-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? "Copying the backend.service code"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Reloading the Daemon"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting the Backend"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling the Backend"

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the mysql"

mysql -h mysql.chenchudaws82s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting the Mysql Root Password"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Restarting the backend"






