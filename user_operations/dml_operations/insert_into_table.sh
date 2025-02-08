#!/bin/bash
. ./functions/functions.sh

insertIntoTable() {
    while true; do
        # List all the tables in the selected database
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")

        if [[ $? -eq 1 ]]; then
            db_menu $1  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="Table name cannot be empty."
        else
            # Check if the table exists
            if [[ ! -d "./Databases/$1/$tableName" ]]; then
                zenity --error --width="300" --text="Table [$tableName] does not exist."
            else
                # Read the columns and types from the structure file
                columnDefs=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Columns:" | cut -d ':' -f2)
                
                # Prompt the user for values to insert
                values=$(zenity --entry --title="Insert Values" --text="Enter values for columns [$columnDefs] (comma separated):" --entry-text "value1, value2, ...")
                
                if [[ -z "$values" ]]; then
                    zenity --error --width="300" --text="Values cannot be empty."
                else
                    # Insert values into the table (this is just an example of appending to a file)
                    echo "$values" >> "./Databases/$1/$tableName/data.txt"
                    zenity --info --width="200" --text="Values inserted into [$tableName] successfully."
                    db_menu $1
                    break
                fi
            fi
        fi
    done
}
insertIntoTable $1

