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
                # Ask for the column to update and the new value
                columnName=$(zenity --entry --title="Column to Update" --text="Enter the column name to update:" --entry-text "column_name")
                newValue=$(zenity --entry --title="New Value" --text="Enter the new value for [$columnName]:" --entry-text "new_value")
                
                if [[ -z "$columnName" || -z "$newValue" ]]; then
                    zenity --error --width="300" --text="Column name or new value cannot be empty."
                else
                    # Ask for conditions to match the rows to update (basic implementation)
                    conditions=$(zenity --entry --title="Update Conditions" --text="Enter conditions to update rows (e.g., column_name = 'value'):" --entry-text "column_name = 'value'")

                    if [[ -z "$conditions" ]]; then
                        zenity --error --width="300" --text="Conditions cannot be empty."
                    else
                        # Update matching rows (basic approach: replace text)
                        sed -i "s/$conditions/$columnName = '$newValue'/g" "./Databases/$1/$tableName/data.txt"
                        zenity --info --width="200" --text="Rows matching condition [$conditions] updated in [$tableName]."
                        db_menu $1
                        break
                    fi
                fi
            fi
        fi
    done
}
updateTable $1

