#!/bin/bash
. ./functions/functions.sh

deleteFromTable() {
    while true; do
        # Ask for the table name
        tableName=$(zenity --entry --title="Delete From Table" --text="Enter the table name to delete from:" --entry-text "table_name")
        
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
                # Display current data
                if [[ -f "./Databases/$1/$tableName/data.txt" ]]; then
                    data=$(cat "./Databases/$1/$tableName/data.txt")
                    zenity --text-info --title="Current Data in $tableName" --width=600 --height=400 --readonly --text="$data"
                else
                    zenity --error --width="300" --text="No data found in [$tableName]."
                fi

                # Ask user to edit the data and delete rows
                updatedData=$(zenity --text-info --title="Edit Data for Deletion" --width=600 --height=400 --editable --text="$data")

                if [[ -z "$updatedData" ]]; then
                    zenity --error --width="300" --text="Data cannot be empty."
                else
                    # Save the updated data back (after deletion)
                    echo "$updatedData" > "./Databases/$1/$tableName/data.txt"
                    zenity --info --width="200" --text="Data updated in [$tableName] after deletion."
                    db_menu $1
                    break
                fi
            fi
        fi
    done
}
deleteFromTable $1

