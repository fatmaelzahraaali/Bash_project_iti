#!/bin/bash 

mainMenu()
{
	select opt in "Create Database" "Connect to Database" "List Database" "Drop Database" "Exit"
	do
		case $opt in 
			"Create Database") . ./main_menu/create_db.sh
				;;
			"Connect to Database") . ./main_menu/connect_db.sh
				;;
			"List Database") . ./main_menu/list_db.sh
                                ;;
			"Drop Database") . ./main_menu/drop_db.sh
		        	;;
		        "Exit") exit
				;;
			*) " invalid option ! "
		esac
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
