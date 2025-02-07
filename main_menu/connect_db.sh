#!/bin/bash
. ./functions/functions.sh


# first list all databases in the system
   while true;
    do
        # List available databases and prompt user to select one
        dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")
        
        
        if [ $? -eq 1 ];
       	then
            mainMenu
            exit

#if user choses a certain database the table menu wil be displayed
      elif [[ $? == 0 ]]
     	then
		 tableMenu $dbName
      fi 
done
