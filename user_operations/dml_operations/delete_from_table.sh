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
                # Ask user to input conditions for deletion (basic implementation)
                conditions=$(zenity --entry --title="Delete Conditions" --text="Enter conditions to delete rows (e.g., column_name = 'value'):" --entry-text "column_name = 'value'")

                if [[ -z "$conditions" ]]; then
                    zenity --error --width="300" --text="Conditions cannot be empty."
                else
                    # Simple example: Delete the first row matching conditions (basic functionality)
                    sed -i "/$conditions/d" "./Databases/$1/$tableName/data.txt"
                    zenity --info --width="200" --text="Rows matching condition [$conditions] deleted from [$tableName]."
                    db_menu $1
                    break
                fi
            fi
        fi
    done
}
deleteFromTable $1

