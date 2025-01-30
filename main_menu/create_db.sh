#!/bin/bash

# Take the db name from the user
read -p "Enter a name for the DataBase: " db_name

# The main directory of databases
db_dir="./databases"

# Check if it exists or not
if [ -d "$db_dir/$db_name" ]
then
	echo "This DataBase is already exists."
elif [ ! -d "$db_dir/$db_name" ]
then
	mkdir "$db_dir/$db_name"
	echo "DataBase '$db_name' is created successfully."
else 
	echo "Invalid input." 
	exit
fi	
