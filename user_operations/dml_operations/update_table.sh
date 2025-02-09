#!/bin/bash
. ./functions/functions.sh

updateTable() {
    while true; do
        # Ask for the table name
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="Table name cannot be empty."
        else
            # Check if the table file exists
            tableFile="./Databases/$1/$tableName/data.txt"
            if [[ ! -f "$tableFile" ]]; then
                zenity --error --width="300" --text="Table [$tableName] does not exist."
            else
                # Ask for the primary key value to update
                primaryKey=$(zenity --entry --title="Update Row" --text="Enter Primary Key Value to Update:" --entry-text "")

                if [[ -z "$primaryKey" ]]; then
                    zenity --error --width="300" --text="Primary key cannot be empty."
                else
                    # Check if the primary key exists in the table
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        zenity --error --width="300" --text="Row with Primary Key [$primaryKey] does not exist."
                    else
                        # Ask for the new data for the entire row
                        newData=$(zenity --entry --title="New Data" --text="Enter new data for the row (format: id,name,age):" --entry-text "")
                        
                        if [[ -z "$newData" ]]; then
                            zenity --error --width="300" --text="New data cannot be empty."
                        else
                            # Update the row where the primary key matches
                            awk -F, -v key="$primaryKey" -v newData="$newData" 'BEGIN {OFS=","} {if ($1 == key) print newData; else print $0}' "$tableFile" > temp.txt && mv temp.txt "$tableFile"

                            zenity --info --width="200" --text="Row with Primary Key [$primaryKey] updated in [$tableName]."
                            db_menu $1
                            break  # Exit loop after successful update
                        fi
                    fi
                fi
            fi
        fi
    done
}

updateTable $1
