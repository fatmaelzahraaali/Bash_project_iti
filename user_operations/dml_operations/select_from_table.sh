#!/bin/bash
. ./functions/functions.sh

selectFromTable() {
    while true; do
        # Ask for the table name
        tableName=$(zenity --entry --title="Select From Table" --text="Enter the table name to select from:" --entry-text "table_name")
        
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
                # Display the data in the table
                if [[ -f "./Databases/$1/$tableName/data.txt" ]]; then
                    data=$(cat "./Databases/$1/$tableName/data.txt")
                    zenity --text-info --title="Data in $tableName" --width=600 --height=400 --readonly --text="$data"
                else
                    zenity --error --width="300" --text="No data found in [$tableName]."
                fi
                db_menu $1
                break
            fi
        fi
    done
}
selectFromTable $1

