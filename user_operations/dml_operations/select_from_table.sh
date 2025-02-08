#!/bin/bash
. ./functions/functions.sh

selectFromTable() {
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
                # Display the data in the table
                if [[ -f "./Databases/$1/$tableName/data.txt" ]]; then
                    data=$(cat "./Databases/$1/$tableName/data.txt")
                    zenity --info --width="400" --text="Data in [$tableName]:\n$data"
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

