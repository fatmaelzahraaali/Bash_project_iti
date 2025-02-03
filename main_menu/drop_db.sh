#!/bin/bash
. ./functions/functions.sh


if [ $? -eq 1 ]
then
   mainMenu
fi


# check if there is any database found to be deleted 
if [ -z "$(ls -A Databases)" ];
  then
        zenity --error --width="200" --text="No Database Found"
        mainMenu
fi



# listing the database       
while true;
do
      dbName="$(ls -l Databases | grep "^d" | awk -F ' ' '{print $9}' | zenity --list --height="400" --width="400" --cancel-label="Back"  --title="Database List" --text="Select your database"  --column="Database name" 2>>.errorlog)"
if [[ -z $dbName ]];
then
     zenity --error --width="200" --text="Database Doesnot exist"
else
     break
fi
done


if  isDatabaseExist $dbName ;
then
        zenity --warning --width="200" --text="Database Can't be reached after Drop"
        rm -r Databases/$dbName
        zenity --notification --width="200" --text="$dbName Deleted Successfully"
        mainMenu
 else
        mainMenu
 fi
