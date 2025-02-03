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
####### this function creates database #######

createDatabase()
{

  mkdir ./Databases/$1
  mkdir ./Databases/$1/.metadata

}

listDatabases() 
{
    

    while true;
    do
        # List available databases and prompt user to select one
        dbName=$(ls -l Databases | grep "^d" | awk '{print $9}' | zenity --cancel-label="Back" --list --height="450" --width="400" --title="Database List" --text="Select your database" --column="Database name")
        
        
        if [ $? -eq 1 ] || [$? -eq 0];
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


db_menu()
{
        select opt in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"
        do
                case $opt in 
                        "Create Table") . ./create_table.sh
                                ;;
                        "List Tables") . ./list_tables.sh
                                ;;
                        "Drop Table") . ./drop_table.sh
                                ;;
                        "Insert into Table") . ./insert_table.sh
                                ;;
			"Select From Table") . ./select_table.sh
				;;
			"Delete From Table") . ./delete_table.sh
				;;
			"Update Table") . ./update_table.sh
				;;
                        "Exit") exit
                                ;;
                        *) " invalid option ! "
                esac
        done
}
