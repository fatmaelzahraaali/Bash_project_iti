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
          exit 0
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
  mkdir ./Databases/$1/.metadata

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
        if [ -z "$dbName" ]
       	then
            zenity --error --width="230" --text="Database field cannot be empty"
        else
            if isDatabaseExist "$dbName";
	    then
                break
            else
                zenity --error --width="200" --text="Database [$dbName] does not exist"
            fi
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
        mainMenu  # Go back to the main menu
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
            # Check if the table exists
            if [[ ! -d "./Databases/$1/$tableName" ]]; then
                zenity --error --width="300" --text="Table [$tableName] does not exist."
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
                    # Check if the primary key exists in the table
                    if ! grep -q "^$primaryKey," "$tableFile"; then
                        zenity --error --width="300" --text="Row with Primary Key [$primaryKey] does not exist."
                    else
                        # Delete row where the first column (primary key) matches the entered value
                        awk -F, -v key="$primaryKey" 'NR==1 || $1 != key' "$tableFile" > temp.txt && mv temp.txt "$tableFile"

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

