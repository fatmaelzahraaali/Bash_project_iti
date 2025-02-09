#!/bin/bash
. ./functions/functions.sh

insertIntoTable() {
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
                # Read the columns and types from the structure file
                columnDefs=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Columns:" | cut -d ':' -f2)
                primaryKey=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Primary Key:" | cut -d ':' -f2 | xargs)  # Get the primary key column name

                # Prompt the user for values to insert
                values=$(zenity --entry --title="Insert Values" --text="Enter values for columns [$columnDefs] (comma separated):" --entry-text "value1, value2, ...")
                
                if [[ -z "$values" ]]; then
                    zenity --error --width="300" --text="Values cannot be empty."
                else
                    # Split the values into an array
                    IFS=',' read -r -a valueArray <<< "$values"
                    
                    # Validate data types
                    IFS=',' read -r -a columnArray <<< "$columnDefs"
                    validDataTypes=true

                    for i in "${!columnArray[@]}"; do
                        columnType=$(echo "${columnArray[$i]}" | awk '{print $2}' | tr '[:lower:]' '[:upper:]')  # Get the data type and convert to uppercase
                        value=${valueArray[$i]}

                        # Check for primary key validity
                        if [[ "$primaryKey" == "${columnArray[$i]}" && -z "$value" ]]; then
                            zenity --error --width="300" --text="Primary key cannot be null."
                            validDataTypes=false
                            break
                        fi

                        # Validate the data type
                        case "$columnType" in
                            "INT")
                                if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                                    zenity --error --width="300" --text="Value [$value] for column [${columnArray[$i]}] must be an integer."
                                    validDataTypes=false
                                    break
                                fi
                                ;;
                            "VARCHAR")
                                # No specific validation for VARCHAR, but you can add length checks if needed
                                ;;
                            "DATE")
                                if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                                    zenity --error --width="300" --text="Value [$value] for column [${columnArray[$i]}] must be in YYYY-MM-DD format."
                                    validDataTypes=false
                                    break
                                fi
                                ;;
                            "FLOAT")
                                if ! [[ "$value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
                                    zenity --error --width="300" --text="Value [$value] for column [${columnArray[$i]}] must be a float."
                                    validDataTypes=false
                                    break
                                fi
                                ;;
                            *)
                                zenity --error --width="300" --text="Unknown data type [$columnType] for column [${columnArray[$i]}]."
                                validDataTypes=false
                                break
                                ;;
                        esac
                    done

                    if [[ "$validDataTypes" == true ]]; then
                        # Check if the primary key already exists
                        if [[ -n "$primaryKey" ]]; then
                            primaryKeyValue=${valueArray[0]}  # Assuming the primary key is the first value
                            if [[ -z "$primaryKeyValue" ]]; then
                                zenity --error --width="300" --text="Primary key cannot be null."
                                continue
                            fi

                            if grep -q "^$primaryKeyValue," "./Databases/$1/$tableName/data.txt"; then
                                zenity --error --width="300" --text="Primary Key [$primaryKeyValue] already exists. Duplicate entry not allowed."
                                continue
                            fi
                        fi

                        # Insert values into the table
                        echo "$values" >> "./Databases/$1/$tableName/data.txt"
                        zenity --info --width="200" --text="Values inserted into [$tableName] successfully."
                        db_menu $1
                        break
                    fi
                fi
            fi
        fi
    done
}
insertIntoTable $1
