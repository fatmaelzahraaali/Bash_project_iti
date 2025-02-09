#!/bin/bash 
RED='\033[1;31m'	          # Red Color code 
Green='\033[1;32m'	        # Green Color Green
ColorReset='\033[0m' 		    # No Color Code

mainMenu()
{
     choice=$(zenity --list \
         --height="450"\
         --width="400"\
         --cancel-label="Exit" \
         --title="Main Menu" \
         --column="Option" \
         "Create Database" \
         "List Database" \
         "Connect To Database" \
         "Drop Database")

     if [ $? -eq 1 ]         #Checks if the exit status of the last command is 1
     then
          echo -e "${Green}Exited..${ColorReset}"
          exit 
     fi
 
     case $choice in 
		"Create Database") ./main_menu/create_db.sh;;
		"List Database") ./main_menu/list_db.sh;;
		"Connect To Database") ./main_menu/connect_db.sh;;
		"Drop Database") ./main_menu/drop_db.sh;;
		*) echo -e "${RED}invalid choice, try again ... you must choose only from the above list${ColorReset}";

        	mainMenu          #Call it again
       esac
}


############################### creating db functions #########################
### this function checks if the database already exist or not ####

isDatabaseExist()
{
  if [ -d ./Databases/$1 ]
  then
	  return 0          #returns  0 if true (exist)
  else
	  return 1          #returns 1 if false (not exist)
  fi

}
####### this function creates database #############

createDatabase()
{
  if [ ! -d "./Databases" ]
  then 
      	mkdir ./Databases
  fi
  mkdir ./Databases/$1

}
################# list databases ###################
listDatabases() 
{
    

    while true;
    do
        # List available databases and prompt user to select one
        dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")
        
        
        if [ $? -eq 0 ] || [ $? -eq 1 ];
       	then
            mainMenu
            return
        fi
        #if [ -z "$dbName" ] #check the length of the entered database name if empty gives error
       	#then
        #    zenity --error --width="230" --text="Database field cannot be empty"
        #else
        #    if isDatabaseExist "$dbName";
	#    then
        #        break
        #    else
        #        zenity --error --width="200" --text="Database [$dbName] does not exist"
        #    fi
        #fi
    done
}
################## Connect to database #################
connect_to_db()
{
while true; do
    # List available databases and prompt user to select one
    dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")

    # If the user presses "Back" (exit dialog), return to mainMenu
    if [ $? -eq 1 ]; then
        mainMenu
        return
    fi

    # If there are databases available 
    if [ "$dbName" ]; then
        db_menu "$dbName"
	return
    fi
    
done
}
################## Secondry Menu #######################
db_menu()
{

    # Ask the user to select an option from the menu
    choice=$(zenity --list \
        --height="450"\
        --width="400"\
        --cancel-label="Back" \
        --title="Table $1 Menu" \
        --column="Option" \
        "Create Table" \
        "List Tables" \
        "Drop Table" \
        "Insert Into Table" \
        "Select From Table" \
        "Delete From Table" \
        "Update Table" )

    if [ $? -eq 1 ]  # If user presses "Back" or closes the dialog
    then
        connect_to_db  # Go back to the databases list
        return
    fi

    # Handle each choice with case statement
    case $choice in
        "Create Table") 
            ./user_operations/ddl_operations/create_table.sh $1;;
        "List Tables") 
            ./user_operations/ddl_operations/list_tables.sh $1;;
        "Drop Table") 
            ./user_operations/ddl_operations/drop_table.sh $1;;
        "Insert Into Table") 
            ./user_operations/dml_operations/insert_into_table.sh $1;;
        "Select From Table") 
            ./user_operations/dml_operations/select_from_table.sh $1;;
        "Delete From Table") 
            ./user_operations/dml_operations/delete_from_table.sh $1;;
        "Update Table") 
            ./user_operations/dml_operations/update_table.sh $1;;

        *)
            # If the user selects an invalid option, show an error message and go back to the menu
            echo -e "${RED}Invalid option! Please try again.${ColorReset}"
            db_menu $1  # Call the menu function again to retry
    esac

}
#################### Create Table #########################
createTable() {
    while true; do
        # Ask user for table name
        tableName=$(zenity --entry --title="Create Table" --text="Enter table name:" --entry-text "Table_name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1  # Go back to the database menu if the user presses cancel
            return
        fi
        # -z check if the table name is empty
        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="Table name cannot be empty."
        else
            # Define valid data types
            validDataTypes=("INT" "VARCHAR" "DATE" "FLOAT")
            dataTypeOptions=$(printf "%s\," "${validDataTypes[@]}"  | sed 's/,$//')

            # Ask for columns and their types
            columns=$(zenity --entry --title="Columns Definition" --text="Enter columns and types in format: column1 type1, column2 type2, ...\nValid types: [$dataTypeOptions]" --entry-text "column_name type")
            
            if [[ -z "$columns" ]]; then
                zenity --error --width="300" --text="Column definition cannot be empty."
            else
                #Validate column definitions
                IFS=',' read -r -a columnArray <<< "$columns"
                validColumns=true

                for column in "${columnArray[@]}"; do
                    columnName=$(echo "$column" | awk '{print $1}')
                    columnType=$(echo "$column" | awk '{print $2}')

                    if [[ ! " ${validDataTypes[@]} " =~ " ${columnType^^} " ]]; then
                        zenity --error --width="300" --text="Invalid data type [$columnType] for column [$columnName]. Valid types are: [$dataTypeOptions]."
                        validColumns=false
                        break
                    fi
                done
		

                if [[ "$validColumns" == true ]]; then
                    # Ask for primary key column
                    primaryKey=$(zenity --entry --title="Primary Key" --text="Enter the primary key column (must be entered):")
                    
                    if [[ -z "$primaryKey" ]]; then
			zenity --error --width="300" --text="Primary key must be entered."
			createTable $1
                       return 
                    else
                        primaryKeyOption="$primaryKey"
                    fi

                    # Create table directory and structure
                    tableDir="./Databases/$1/$tableName"
                    mkdir -p "$tableDir"
                    echo "Columns: $columns" > "$tableDir/structure.txt"
                    echo "Primary Key: $primaryKeyOption" >> "$tableDir/structure.txt"
                    
                    # Save the column names (not including the types) as a single row in data.txt (comma-separated)
                    columnNames=$(echo "$columns" | sed 's/,/\n/g' | cut -d ' ' -f1 | tr '\n' ',' | sed 's/,$//')
                    echo "$columnNames" > "$tableDir/data.txt"
                    
                    zenity --info --width="200" --text="Table [$tableName] created successfully"
                    db_menu $1
                    break
                fi
            fi
        fi
    done
}
#################### List Tables ###########################

listTables() {
    tableList=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}')
    if [[ -z "$tableList" ]]; then
        zenity --error --width="200" --text="No tables found in [$1]."
    else
        zenity --info --width="400" --text="Tables in [$1]:\n$tableList"
    fi
    db_menu $1
}
#################### Drop Table #############################
dropTable() {
    while true; do
        # List tables to choose one to drop
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")

        if [[ $? -eq 1 ]]; then
            db_menu $1
            return
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="200" --text="No table selected."
        else
            zenity --warning --width="300" --text="Are you sure you want to delete table [$tableName]?"
            rm -r ./Databases/$1/$tableName
            zenity --notification --width="200" --text="Table [$tableName] deleted successfully."
            db_menu $1
            break
        fi
    done
}
#################### Select from Table ######################
selectFromTable() {
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
                # Display the data in the table
                if [[ -f "./Databases/$1/$tableName/data.txt" ]]; then
                    data=$(cat "./Databases/$1/$tableName/data.txt")
                    zenity --info --width="400" --text="Data in [$tableName]:\n$data"
                else
                    zenity --error --width="300" --text="No data found in [$tableName]."
                fi
                db_menu $1
                break
        fi
    done
}
#################### Delete from table ######################

deleteFromTable() {
    while true; do
        # Ask for the table name
        tableName=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}' | zenity --list --height="400" --width="400" --title="Select Table" --column="Table Name")
        
        if [[ $? -eq 1 ]]; then
            db_menu $1
            return  # Exit if user presses cancel
        fi

        if [[ -z "$tableName" ]]; then
            zenity --error --width="300" --text="There are no tables to delete."
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
		    # -q return 0 is the primary key found and 1 if not found
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        zenity --error --width="300" --text="Row with Primary Key [$primaryKey] does not exist."
                    else
                        # Delete row where the first column (primary key) matches the entered value
                        sed -i "/^$primaryKey,/d" "$tableFile"

                        zenity --info --width="200" --text="Row with Primary Key [$primaryKey] deleted from [$tableName]."
                        db_menu $1
                        break  # Exit loop after successful deletion
                    fi
                fi
            fi
        fi
    done
}

#################### Update table #########################

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
                        # Read the columns and types from the structure file
                        columnDefs=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Columns:" | cut -d ':' -f2)
                        primaryKeyColumn=$(cat "./Databases/$1/$tableName/structure.txt" | grep "Primary Key:" | cut -d ':' -f2 | xargs)  # Get the primary key column name

                        # Prompt the user for new values
                        newValues=$(zenity --entry --title="Update Data" --text="Enter new values for columns [$columnDefs] (comma separated):" --entry-text "")

                        if [[ -z "$newValues" ]]; then
                            zenity --error --width="300" --text="New data cannot be empty."
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
                                        zenity --error --width="300" --text="Primary key cannot be null."
                                        validDataTypes=false
                                        break
                                    fi

                                    # Check if the new primary key already exists (if it's being changed)
                                    if [[ "$value" != "$primaryKey" ]] && grep -q "^$value," "$tableFile"; then
                                        zenity --error --width="300" --text="Primary Key [$value] already exists. Duplicate entry not allowed."
                                        validDataTypes=false
                                        break
                                    fi
                                fi

                                # Validate the data type
                                case "$columnType" in
                                    "INT")
                                        if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
                                            zenity --error --width="300" --text="Value [$value] for column [$columnName] must be an integer."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    "VARCHAR")
                                        # No specific validation for VARCHAR, but you can add length checks if needed
                                        ;;
                                    "DATE")
                                        if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                                            zenity --error --width="300" --text="Value [$value] for column [$columnName] must be in YYYY-MM-DD format."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    "FLOAT")
                                        if ! [[ "$value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
                                            zenity --error --width="300" --text="Value [$value] for column [$columnName] must be a float."
                                            validDataTypes=false
                                            break
                                        fi
                                        ;;
                                    *)
                                        zenity --error --width="300" --text="Unknown data type [$columnType] for column [$columnName]."
                                        validDataTypes=false
                                        break
                                        ;;
                                esac
                            done

                            if [[ "$validDataTypes" == true ]]; then
                                # Update the row where the primary key matches
                                sed -i "/^$primaryKey,/c\\$newValues" "$tableFile"
                                zenity --info --width="200" --text="Row with Primary Key [$primaryKey] updated in [$tableName]."
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
###################### insert into table #####################
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
