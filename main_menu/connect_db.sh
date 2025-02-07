#!/bin/bash
. ./functions/functions.sh

# First, list all databases in the system
while true; do
    # List available databases and prompt user to select one
    dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")

    # If the user presses "Back" (exit dialog), return to mainMenu
    if [ $? -eq 1 ]; then
        mainMenu
        exit
    fi

    # If the user selects a valid database (dbName is not empty)
    if [ -n "$dbName" ]; then
        # Check if the selected database exists
        if isDatabaseExist "$dbName"; then
            # Call the db_menu function with the selected dbName
            db_menu "$dbName"
        else
            # Show error message if the database doesn't exist
            zenity --error --width="300" --text="Database [$dbName] does not exist."
        fi
    else
        # If no database is selected, show an error message
        zenity --error --width="300" --text="Please select a valid database."
    fi
done

