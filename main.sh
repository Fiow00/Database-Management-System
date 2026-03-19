#! /bin/bash

# Source scripts
source scripts/db_operations.sh
source scripts/table_operations.sh
source scripts/helpers.sh

# Global variable
current_db=""

# Main menu
PS3="Choose an option: "

options=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit")

select option in "${options[@]}"
do
    case $option in
        "Create Database")
            echo "Create Database selected"
            ;;
        "List Databases")
            echo "List Databases selected"
            ;;
        "Connect to Database")
            echo "Connect to Database selected"
            ;;
        "Exit")
            echo "GoodBye"
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
