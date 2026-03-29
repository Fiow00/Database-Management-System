#! /bin/bash

# Source scripts
source scripts/db_operations.sh
source scripts/table_operations.sh
source scripts/helpers.sh

# Global variable
current_db=""

# Main menu
while true
    do
        PS3="Choose an option: "

        options=("Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit")

        select option in "${options[@]}"
        do
            case $option in
                "Create Database")
                    create_database
                    break
                    ;;
                "List Databases")
                    list_databases
                    break
                    ;;
                "Connect to Database")
                    connect_database
                    break
                    ;;
                "Drop Database")
                    drop_database
                    break
                    ;;
                "Exit")
                    echo "GoodBye"
                    exit
                    ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
        done
    done
