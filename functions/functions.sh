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
####### this function creates database #######

createDatabase()
{
  if [ ! -d "./Databases" ]
  then 
      	mkdir ./Databases
  fi
  mkdir ./Databases/$1
  mkdir ./Databases/$1/.metadata

}

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

tableMenu()
{

  choice=$(zenity --list \
  --height="450"\
  --width="400"\
  --cancel-label="Back" \
  --title="Table $2 Menu" \
  --column="Option" \
     "create Table [$2]" \
     "Drop Table [$2]" \
     "list Tables [$2]" \
     "Main Menu" \
     "Exit")

        if [ $? -eq 1 ]
        then
            mainMenu 
        fi

case $choice in
    "create Table [$2]"). ./user_operations/ddl_operations/create_table.sh $1 $2;;
    "list Tables [$2]"). ./user_operations/ddl_operations/list_tables.sh $1 $2;;
    "Drop Table [$2]"). ./user_operations/ddl_operations/drop_table.sh $1 $2;;
    "Insert Into Table [$2]"). ./user_operations/dml_operations/insert_into_table.sh $1 $2;;
    "Select From Table [$2]"). ./user_operations/dml_operations/select_from_table.sh $1 $2;;
    "Delete From Table [$2]"). ./user_operations/dml_operations/delete_from_table.sh $1 $2;;
    "Update Table [$2]"). ./user_operations/dml_operations/update_table.sh $1 $2;;
    "Main Menu") mainMenu;;
    "Exit") echo -e "${Green}Exited..${ColorReset}";exit;; #exit from database
    *) echo -e "${RED}invalid choice, try again ... you must choose only from the above list${ColorReset}"; mainMenu          #Call it again
esac

}
##########Secondry Menu###########
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
