#! /bin/bash

create_database() {
    read -p "Enter database name: " db_name

    # Check if empty
    if [[ -z "$db_name" ]]
    then
        echo "Database name cannot be empty"
        return
    fi

    # Check if already exists
    if [[ -d "databases/$db_name" ]]
    then
        echo "Database already exists"
    else
        mkdir "databases/$db_name"
        echo "Database '$db_name' created successfully"
    fi
}

list_databases() {
    # Check if databases directory is empty
    if [ -z "$(ls databases)" ]
    then
        echo "No databases were found"
    else
        echo "Databases: "
        ls databases
    fi
}
