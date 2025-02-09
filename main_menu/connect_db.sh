#!/bin/bash
. ./functions/functions.sh

# First, list all databases in the system
connect_to_db()
{
while true; do
    # List available databases and prompt user to select one
    dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")

    # If the user presses "Back" (exit dialog), return to mainMenu
    if [ $? -eq 1 ]; then
        mainMenu
        return
    fi

    # If the user selects a valid database 
    if [ -n "$dbName" ]; then
        db_menu "$dbName"
	return
    fi
    
done
}
connect_to_db

