#!/bin/bash 
RED='\033[1;31m'          # Red Color code 
GREEN='\033[1;32m'        # Green Color code
COLOR_RESET='\033[0m'     # No Color Code

# Function to display an error message
show_error() {
    zenity --error --width="300" --text="$1"
}

# Function to display an info message
show_info() {
    zenity --info --width="200" --text="$1"
}

# Main menu function
mainMenu() {
    choice=$(zenity --list \
        --height="450" \
        --width="400" \
        --cancel-label="Exit" \
        --title="Main Menu" \
        --column="Option" \
        "Create Database" \
        "List Database" \
        "Connect To Database" \
        "Drop Database")

    if [[ $? -eq 1 ]]; then  # Checks if the exit status of the last command is 1
        echo -e "${GREEN}Exited..${COLOR_RESET}"
        exit 
    fi

    case $choice in 
        "Create Database") ./main_menu/create_db.sh;;
        "List Database") ./main_menu/list_db.sh;;
        "Connect To Database") ./main_menu/connect_db.sh;;
        "Drop Database") ./main_menu/drop_db.sh;;
        *) show_error "Invalid choice, try again ... you must choose only from the above list"; mainMenu ;;
    esac
}

# Check if the database exists
isDatabaseExist() {
    [[ -d "./Databases/$1" ]]
}

# Create a new database
createDatabase() {
    mkdir -p "./Databases/$1"
}

# List available databases
listDatabases() {
    while true; do
        dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")
        
        if [[ $? -eq 1 ]]; then
            mainMenu
            return
        fi

        if [[ -n "$dbName" ]] && isDatabaseExist "$dbName" ; then
            break
        else
            show_error "Database [$dbName] does not exist or no database selected."
        fi
    done
}

# Connect to a selected database
connect_to_db() {
    while true; do
        dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")

        if [[ $? -eq 1 ]]; then
            mainMenu
            return
        fi

        if [[ -n "$dbName" ]]; then
            db_menu "$dbName"
            return
        fi
    done
}

# Secondary menu for table operations
db_menu() {
    choice=$(zenity --list \
        --height="450" \
        --width="400" \
        --cancel-label="Back" \
        --title="Table $1 Menu" \
        --column="Option" \
        "Create Table" \
        "List Tables" \
        "Drop Table" \
        "Insert Into Table" \
        "Select From Table" \
        "Delete From Table" \
        "Update Table")

    if [[ $? -eq 1 ]]; then
        connect_to_db  # Go back to the databases list
        return
    fi

    case $choice in
        "Create Table") ./user_operations/ddl_operations/create_table.sh "$1";;
        "List Tables") ./user_operations/ddl_operations/list_tables.sh "$1";;
        "Drop Table") ./user_operations/ddl_operations/drop_table.sh "$1";;
        "Insert Into Table") ./user_operations/dml_operations/insert_into_table.sh "$1";;
        "Select From Table") ./user_operations/dml_operations/select_from_table.sh "$1";;
        "Delete From Table") ./user_operations/dml_operations/delete_from_table.sh "$1";;
        "Update Table") ./user_operations/dml_operations/update_table.sh "$1";;
        *) show_error "Invalid option! Please try again."; db_menu "$1";;
    esac
}

# Create a new table
createTable() {
    while true; do
        tableName=$(zenity --entry --title="Create Table" --text="Enter table name:" --entry-text "Table_name")
        
        if [[ $? -eq 1 ]]; then
            db_menu "$1"  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then
            show_error "Table name cannot be empty."
        else
            validDataTypes=("INT" "VARCHAR" "DATE" "FLOAT")
            dataTypeOptions=$(printf "%s," "${validDataTypes[@]}" | sed 's/,$//')

            columns=$(zenity --entry --title="Columns Definition" --text="Enter columns and types in format: column1 type1, column2 type2, ...\nValid types: [$dataTypeOptions]" --entry-text "column_name type")
            
            if [[ -z "$columns" ]]; then
                show_error "Column definition cannot be empty."
            else
                IFS=',' read -r -a columnArray <<< "$columns"
                validColumns=true

                for column in "${columnArray[@]}"; do
                    columnName=$(echo "$column" | awk '{print $1}')
                    columnType=$(echo "$column" | awk '{print $2}')

                    if [[ ! " ${validDataTypes[@]} " =~ " ${columnType^^} " ]]; then
                        show_error "Invalid data type [$columnType] for column [$columnName]. Valid types are: [$dataTypeOptions]."
                        validColumns=false
                        break
                    fi
                done

                if [[ "$validColumns" == true ]]; then
                    primaryKey=$(zenity --entry --title="Primary Key" --text="Enter the primary key column (must be entered):")
                    
                    if [[ -z "$primaryKey" ]]; then
                        show_error "Primary key must be entered."
                        continue
                    fi

                    tableDir="./Databases/$1/$tableName"
                    mkdir -p "$tableDir"
                    echo "Columns: $columns" > "$tableDir/structure.txt"
                    echo "Primary Key: $primaryKey" >> "$tableDir/structure.txt"
                    
                    columnNames=$(echo "$columns" | sed 's/,/\n/g' | cut -d ' ' -f1 | tr '\n' ',' | sed 's/,$//')
                    echo "$columnNames" > "$tableDir/data.txt"
                    
                    show_info "Table [$tableName] created successfully."
                    db_menu "$1"
                    break
                fi
            fi
        fi
    done
}

# List tables in the selected database
listTables() {
    tableList=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}')
    if [[ -z "$tableList" ]]; then
        show_error "No tables found in [$1]."
    else
        show_info "Tables in [$1]:\n$tableList"
    fi
    db_menu "$1"
}

# Drop a selected table
dropTable() {
    while true; do
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")

        if [[ $? -eq 1 ]]; then
            db_menu "$1"
            return
        fi

        if [[ -z "$tableName" ]]; then
            show_error "No table selected."
        else
            zenity --warning --width="300" --text="Are you sure you want to delete table [$tableName]?"
            rm -r "./Databases/$1/$tableName"
            show_info "Table [$tableName] deleted successfully."
            db_menu "$1"
            break
        fi
    done
}

# Select data from a table
selectFromTable() {
    while true; do
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")

        if [[ $? -eq 1 ]]; then
            db_menu "$1"  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then
            show_error "Table name cannot be empty."
        else
            if [[ -f "./Databases/$1/$tableName/data.txt" ]]; then
                data=$(cat "./Databases/$1/$tableName/data.txt")
                show_info "Data in [$tableName]:\n$data"
            else
                show_error "No data found in [$tableName]."
            fi
            db_menu "$1"
            break
        fi
    done
}

# Delete a row from a table
deleteFromTable() {
    while true; do
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")
        
        if [[ $? -eq 1 ]]; then
            db_menu "$1"
            return
        fi

        if [[ -z "$tableName" ]]; then
            show_error "There are no tables to delete."
        else
            tableFile="./Databases/$1/$tableName/data.txt"
            if [[ ! -f "$tableFile" ]]; then
                show_error "Table [$tableName] does not exist."
            else
                primaryKey=$(zenity --entry --title="Delete Row" --text="Enter Primary Key Value to Delete:" --entry-text "")
                if [[ -z "$primaryKey" ]]; then
                    show_error "Primary key cannot be empty."
                else
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        show_error "Row with Primary Key [$primaryKey] does not exist."
                    else
                        sed -i "/^$primaryKey,/d" "$tableFile"
                        show_info "Row with Primary Key [$primaryKey] deleted from [$tableName]."
                        db_menu "$1"
                        break
                    fi
                fi
            fi
        fi
    done
}
# Update a row in a table
updateTable() {
    while true; do
        # Ask for the table name
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1  # Go back to the database menu if the user presses cancel
            return
        fi

        if [[ -z "$tableName" ]]; then

            show_error "Table name cannot be empty."

        else

            tableFile="./Databases/$1/$tableName/data.txt"
            if [[ ! -f "$tableFile" ]]; then
                show_error "Table [$tableName] does not exist."
            else
                # Ask for the primary key value to update
                primaryKey=$(zenity --entry --title="Update Row" --text="Enter Primary Key Value to Update:" --entry-text "")

                if [[ -z "$primaryKey" ]]; then
                    show_error "Primary key cannot be empty."
                else
                    # Check if the primary key exists in the table
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        show_error "Row with Primary Key [$primaryKey] does not exist."
                    else
                        # Read the columns and types from the structure file
                        columnDefs=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Columns:" | cut -d ':' -f2)
                        primaryKeyColumn=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Primary Key:" | cut -d ':' -f2 | xargs)  # Get the primary key column name

                        # Prompt the user for new values
                        newValues=$(zenity --entry --title="Update Data" --text="Enter new values for columns [$columnDefs] (comma separated):" --entry-text "")

                        if [[ -z "$newValues" ]]; then
                            show_error "New data cannot be empty."
                        else
                            # Split the new values into an array
                            IFS=',' read -r -a newValueArray <<< "$newValues"

                            # Validate data types
                            IFS=',' read -r -a columnArray <<< "$columnDefs"
                            validDataTypes=true

                            for i in "${!columnArray[@]}"; do
                                columnName=$(echo "${columnArray[$i]}" | awk '{print $1}')
                                columnType=$(echo "${columnArray[$i]}" | awk '{print $2}' | tr '[:lower:]' '[:upper:]')  # Get the data type and convert to uppercase
                                value=${newValueArray[$i]}

                                # Check for primary key validity
                                if [[ "$primaryKeyColumn" == "$columnName" ]]; then
                                    if [[ -z "$value" ]]; then
                                        show_error "Primary key cannot be null."
                                        validDataTypes=false
                                        break
                                    fi

                                    # Check if the new primary key already exists (if it's being changed)
                                    if [[ "$value" != "$primaryKey" ]] && grep -q "^$value," "$tableFile"; then
                                        show_error "Primary Key [$value] already exists. Duplicate entry not allowed."
                                        validDataTypes=false
                                        break
                                    fi
                                fi

                                # Validate the data type
                                case "$columnType" in
                                    "INT")
                                        if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                                            show_error "Value [$value] for column [$columnName] must be an integer."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    "VARCHAR")
                                        if ! [[ "$value" =~ ^[a-zA-Z0-9_.,-]*$ ]]; then
                                            show_error "Value [$value] for column [$columnName] must be alphanumeric and may contain (, . - _)"
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    "DATE")
                                        if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                                            show_error "Value [$value] for column [$columnName] must be in YYYY-MM-DD format."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    "FLOAT")
                                        if ! [[ "$value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
                                            show_error "Value [$value] for column [$columnName] must be a float."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    *)
                                        show_error "Unknown data type [$columnType] for column [$columnName]."
                                        validDataTypes=false
                                        break
                                        ;;
                                esac
                            done

                            if [[ "$validDataTypes" == true ]]; then
                                # Update the row where the primary key matches
				# c replaces the entire matched line with the new values
                                sed -i "/^$primaryKey,/c\\$newValues" "$tableFile"
                                show_info "Row with Primary Key [$primaryKey] updated in [$tableName]."
                                db_menu $1
                                break  # Exit loop after successful update
                            fi
                        fi
                    fi
                fi
            fi
        fi
    done
}
# Insert a new row into a table

insertIntoTable() {

    while true; do

        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")


        if [[ $? -eq 1 ]]; then

            db_menu "$1"  # Go back to the database menu if the user presses cancel

            return

        fi


        if [[ -z "$tableName" ]]; then

            show_error "Table name cannot be empty."

        else

            if [[ ! -d "./Databases/$1/$tableName" ]]; then

                show_error "Table [$tableName] does not exist."

            else

                columnDefs=$(grep "Columns:" "./Databases/$1/$tableName/structure.txt" | cut -d ':' -f2)

                primaryKey=$(grep "Primary Key:" "./Databases/$1/$tableName/structure.txt" | cut -d ':' -f2 | xargs)


                values=$(zenity --entry --title="Insert Values" --text="Enter values for columns [$columnDefs] (comma separated):" --entry-text "value1, value2, ...")


                if [[ -z "$values" ]]; then

                    show_error "Values cannot be empty."

                else

                    IFS=',' read -r -a valueArray <<< "$values"

                    IFS=',' read -r -a columnArray <<< "$columnDefs"

                    validDataTypes=true


                    for i in "${!columnArray[@]}"; do

                        columnType=$(echo "${columnArray[$i]}" | awk '{print $2}' | tr '[:lower:]' '[:upper:]')

                        value=${valueArray[$i]}


                        if [[ "$primaryKey" == "${columnArray[$i]}" && -z "$value" ]]; then

                            show_error "Primary key cannot be null."

                            validDataTypes=false

                            break

                        fi


                        case "$columnType" in

                            "INT")

                                if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then

                                    show_error "Value [$value] for column [${columnArray[$i]}] must be an integer."

                                    validDataTypes=false

                                    break

                                fi

                                ;;

                            "VARCHAR")

                                if ! [[ "$value" =~ ^[a-zA-Z0-9_.,-]*$ ]]; then

                                    show_error "Value [$value] for column [${columnArray[$i]}] must be alphanumeric and may contain (, . - _)."

                                    validDataTypes=false

                                    break

                                fi

                                ;;

                            "DATE")

                                if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then

                                    show_error "Value [$value] for column [${columnArray[$i]}] must be in YYYY-MM-DD format."

                                    validDataTypes=false

                                    break

                                fi

                                ;;

                            "FLOAT")

                                if ! [[ "$value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then

                                    show_error "Value [$value] for column [${columnArray[$i]}] must be a float."

                                    validDataTypes=false

                                    break

                                fi

                                ;;

                            *)

                                show_error "Unknown data type [$columnType] for column [${columnArray[$i]}]."

                                validDataTypes=false

                                break

                                ;;

                        esac

                    done


                    if [[ "$validDataTypes" == true ]]; then

                        if [[ -n "$primaryKey" ]]; then

 primaryKeyValue=${valueArray[0]}  # Assuming the primary key is the first value

                            if [[ -z "$primaryKeyValue" ]]; then

                                show_error "Primary key cannot be null."

                                continue

                            fi


                            if grep -q "^$primaryKeyValue," "./Databases/$1/$tableName/data.txt"; then

                                show_error "Primary Key [$primaryKeyValue] already exists. Duplicate entry not allowed."

                                continue

                            fi

                        fi


                        echo "$values" >> "./Databases/$1/$tableName/data.txt"

                        show_info "Values inserted into [$tableName] successfully."

                        db_menu "$1"

                        break

                    fi

                fi

            fi

        fi

    done

}


