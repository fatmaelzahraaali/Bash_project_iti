#!/bin/bash

db_dir="./databases"
echo "Listing Databases:"
for db in "$db_dir"/*/
do
	echo "$(basename "$db")"
done

