#!/bin/bash
. ./functions/functions.sh

deleteFromTable() {
    while true; do
        # Ask for the table name
        tableName=$(zenity --entry --title="Delete From Table" --text="Enter the table name to delete from:" --entry-text "")

        if [[ $? -eq 1 ]]; then
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
                    # Delete row where the first column (primary key) matches the entered value
                    awk -F, -v key="$primaryKey" 'NR==1 || $1 != key' "$tableFile" > temp.txt && mv temp.txt "$tableFile"

                    zenity --info --width="200" --text="Row with Primary Key [$primaryKey] deleted from [$tableName]."
                    break  # Exit loop after successful deletion
                fi
            fi
        fi
    done
}

deleteFromTable $1

