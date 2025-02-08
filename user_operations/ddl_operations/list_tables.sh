#!/bin/bash
. ./functions/functions.sh

listTables() {
    tableList=$(ls -l ./Databases/$1 | grep "^d" | awk '{print $9}')
    if [[ -z "$tableList" ]]; then
        zenity --error --width="200" --text="No tables found in [$1]."
    else
        zenity --info --width="400" --text="Tables in [$1]:\n$tableList"
    fi
    db_menu $1
}
listTables $1
