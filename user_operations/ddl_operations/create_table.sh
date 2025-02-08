#!/bin/bash
. ./functions/functions.sh

createTable() {
    while true; do
        # Ask user for table name
        tableName=$(zenity --entry --title="Create Table" --text="Enter table name:" --entry-text "Table_name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="Table name cannot be empty."
        else
            # Ask for columns and their types
            columns=$(zenity --entry --title="Columns Definition" --text="Enter columns and types in format: column1 type1, column2 type2, ..." --entry-text "column_name type")
            
            if [[ -z "$columns" ]]; then
                zenity --error --width="300" --text="Column definition cannot be empty."
            else
                # Ask for primary key column
                primaryKey=$(zenity --entry --title="Primary Key" --text="Enter the primary key column (leave blank if none):")
                
                if [[ -z "$primaryKey" ]]; then
                    primaryKeyOption="No Primary Key"
                else
                    primaryKeyOption="Primary Key: $primaryKey"
                fi

                # Create table file with the structure
                tableDir="./Databases/$1/$tableName"
                mkdir -p "$tableDir"
                echo "Columns: $columns" > "$tableDir/structure.txt"
                echo "Primary Key: $primaryKeyOption" >> "$tableDir/structure.txt"

                zenity --info --width="200" --text="Table [$tableName] created successfully"
                db_menu $1
                break
            fi
        fi
    done
}
createTable $1
