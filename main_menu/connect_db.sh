#!/bin/bash
. ./functions/functions.sh


# first list all databases in the system
listDatabases

  if [[ $exitCode == 1 ]]
    then
        mainMenu
        exit
    fi
#if user choses a certain database the table menu wil be displayed
#tableMenu $dbName
