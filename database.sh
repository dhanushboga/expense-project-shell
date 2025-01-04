#!/bin/bash

LOG_FOLDER="/var/log/database-logs"
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

mkdir -p $LOG_FOLDER &>>LOG_FILE_NAME
VALIDATE $? "Creating Logs Folder for DataBase-Server"

echo "The $0 Script run at :$TIME_STAMP" &>>LOG_FILE_NAME

dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "Installing MySQL-Server"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE $? "Enabling the mysql"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE $? "Starting the mysqld"

mysql_secure_installation --set-root-pass ExpenseApp@1 ; show databases; &>>LOG_FILE_NAME
if [ $? -ne 0 ]
then
  echo "Mysql password was not been setup"
  mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE_NAME
fi



