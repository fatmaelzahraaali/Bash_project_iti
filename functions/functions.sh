#!/bin/bash 

mainMenu()
{
	select opt in "Create Database" "List Database" "Connect to Database" "Drop Database" "Exit"
	do
		case $opt in 
			"Create Database") . ./main_menu/create_db.sh
				;;
			"List Database") . ./main_menu/list_db.sh
				;;
			"Connect to Database") . ./main_menu/connect_db.sh
				;;
			"Drop Database") . ./main_menu/drop_db.sh
		        	;;
		        "Exit") exit
				;;
			*) " invalid option ! "
		esac
	done
}

mainMenu
