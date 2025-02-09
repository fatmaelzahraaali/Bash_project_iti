#!/bin/bash
. ./functions/functions.sh

deleteFromTable() {
    while true; do
        # Ask for the table name
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1
            return  # Exit if user presses cancel
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="Table name cannot be empty."
        else
            # Check if the table file exists
            tableFile="./Databases/$1/$tableName/data.txt"
            if [[ ! -f "$tableFile" ]]; then
                zenity --error --width="300" --text="Table [$tableName] does not exist."
            else
                # Ask for the primary key value to delete
                primaryKey=$(zenity --entry --title="Delete Row" --text="Enter Primary Key Value to Delete:" --entry-text "")

                if [[ -z "$primaryKey" ]]; then
                    zenity --error --width="300" --text="Primary key cannot be empty."
                else
                    # Check if the primary key exists in the table
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        zenity --error --width="300" --text="Row with Primary Key [$primaryKey] does not exist."
                    else
                        # Delete row where the first column (primary key) matches the entered value
                        awk -F, -v key="$primaryKey" 'NR==1 || $1 != key' "$tableFile" > temp.txt && mv temp.txt "$tableFile"

                        zenity --info --width="200" --text="Row with Primary Key [$primaryKey] deleted from [$tableName]."
                        db_menu $1
                        break  # Exit loop after successful deletion
                    fi
                fi
            fi
        fi
    done
}

deleteFromTable $1
