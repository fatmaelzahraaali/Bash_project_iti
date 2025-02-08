#!/bin/bash
. ./functions/functions.sh

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
dropTable $1
