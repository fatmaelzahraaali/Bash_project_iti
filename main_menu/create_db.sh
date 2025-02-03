#!/bin/bash

. ./functions/functions.sh

while true
do
  
  dbName=$(zenity --entry \
  --title="Add new database" \
  --text="Enter database name:" \
  --cancel-label="cancel"\
  --entry-text "DB_name")

# if cancel return to mainMenu 
  if [[ $? = 1 ]]
  then
      mainMenu
  fi 


  if [[ -z "$dbName" ]] || [[ ! $dbName =~  ^[a-zA-Z]+[a-zA-Z0-9]*$ ]] 
  then
      zenity --error --width="300" --text="Database field cannot be empty or start with space or number or special char"
  else
      # check if the database is exit or not
      if isDatabaseExist $dbName
      then
          zenity --error --width="200" --text="[$dbName] is already exist"   
      else
          createDatabase $dbName

          # check if last command is Done(a datebase name is entered successfully
          if [ $? -eq 0 ]
          then
              
              zenity --info --width="200" --text="[$dbName] created successfully"
              break 
	  else   
              zenity --error --width="200" --text="Error occured during creating the database"   

          fi

        fi
      fi 
done

mainMenu
