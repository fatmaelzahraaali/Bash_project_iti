#!/bin/bash
. ./functions/functions.sh
# Take the database name from the user
read -p "Enter the name of the database you want to connect: " db_name

# Main dirctory of databases
db_dir="./databases"

# Check if the directory already exists
if [ -d "$db_dir/$db_name" ]
then
    cd "$db_dir/$db_name" || { echo "Failed to connect to database."; exit 1; }
    echo "Connected to Database '$db_name'."
    db_menu
else
    echo "DataBase '$db_name' is not found"
fi
