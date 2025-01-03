#!/bin/bash

LOG_FOLDER="/var/log/database_logs"
LOG_FILE=$(echo $0 | cut -d '.' -f1)
TIME_STAMP=$(data +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME=$LOG_FOLDER/$LOG_FILE-$TIME_STAMP.log


USER_ID=(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECK_ROOT(){

if [ USER_ID -ne 0 ]
then
   echo "Error::Please run this script under super access previlages"
   exit 1
fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$2...........$R FAILURE $N"
    else
      echo -e "$2...........$R SUCCESS $N"
    fi
}

dnf install mysql-server -y ?>>LOG_FILE_NAME
VALIDATE $? "Installing MySql-Server"

systemctl enable mysqld ?>>LOG_FILE_NAME
VALIDATE $? "Enabling mysqld"

systemctl start mysqld ?>>LOG_FILE_NAME
VALIDATE $? "Starting the mysqld"


mysql -h mysql.daws82s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
   echo "MySQL Root password not setup" &>>$LOG_FILE_NAME
   mysql_secure_installation --set-root-pass ExpenseApp@1
   VALIDATE $? "Setting the root password"
else
  echo -e "MySQL Root password already setup ... $Y SKIPPING $N" 
fi








