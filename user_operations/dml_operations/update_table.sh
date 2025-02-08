#!/bin/bash
. ./functions/functions.sh

updateTable() {
    while true; do
        # Ask for the table name
        tableName=$(zenity --entry --title="Update Table" --text="Enter the table name to update:" --entry-text "table_name")
        
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
                    zenity --text-info --title="Data in $tableName" --width=600 --height=400 --readonly --text="$data"
                else
                    zenity --error --width="300" --text="No data found in [$tableName]."
                fi

                # Let the user edit specific rows
                updatedData=$(zenity --text-info --title="Edit Data to Update" --width=600 --height=400 --editable --text="$data")

                if [[ -z "$updatedData" ]]; then
                    zenity --error --width="300" --text="Data cannot be empty."
                else
                    # Save the updated data back
                    echo "$updatedData" > "./Databases/$1/$tableName/data.txt"
                    zenity --info --width="200" --text="Data updated successfully in [$tableName]."
                    db_menu $1
                    break
                fi
            fi
        fi
    done
}
updateTable $1

