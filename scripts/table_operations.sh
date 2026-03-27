#!/bin/bash

table_menu() {
    PS3="Choose a table option: "

    options=("Create Table" "List Tables" "Drop Table" "Insert" "Select" "Update" "Delete" "Back")

    select choice in "${options[@]}"
    do
        case $choice in
            "Create Table") create_table ;;
            "List Tables") echo "List Tables selected" ;;
            "Drop Table") echo "Drop Table selected" ;;
            "Insert") insert_into_table ;;
            "Select") select_from_table ;;
            "Update") echo "Update selected" ;;
            "Delete") delete_from_table ;;
            "Back") break ;;
            *) echo "Invalid option" ;;
        esac
    done
}


create_table() {
    if [[ -z "$current_db" ]]; then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name: " table_name

    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    if [[ -f "$current_db/$table_name" ]]; then
        echo "Table already exists"
        return
    fi

    read -p "Enter number of columns: " cols_num

    if ! [[ "$cols_num" =~ ^[0-9]+$ ]]; then
        echo "Invalid number"
        return
    fi

    meta_file="$current_db/$table_name.meta"
    data_file="$current_db/$table_name"

    > "$meta_file"
    > "$data_file"

    for ((i=1; i<=cols_num; i++)); do
        read -p "Column name: " col_name
        read -p "Column type (int/string): " col_type

        if [[ "$col_type" != "int" && "$col_type" != "string" ]]; then
            col_type="string"
        fi

        if [[ $i -eq 1 ]]; then
            echo "$col_name:$col_type:pk" >> "$meta_file"
        else
            echo "$col_name:$col_type" >> "$meta_file"
        fi
    done

    echo "Table created successfully"
}


insert_into_table() {

    # Check if connected to a database
    if [[ -z "$current_db" ]]
    then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name: " table_name

    # Check if table exists
    if [[ ! -f "$current_db/$table_name" ]]
    then
        echo "Table does not exist"
        return
    fi

    meta_file="$current_db/$table_name.meta"
    data_file="$current_db/$table_name"

    row=""

    while IFS=":" read -r column_name column_type column_key <&3
    do
        read -p "Enter value for $column_name ($column_type): " value

        # Check empty value
        if [[ -z "$value" ]]
        then
            echo "Value for '$column_name' cannot be empty"
            return
        fi

        # Type validation
        if [[ "$column_type" == "int" ]]
        then
            if ! [[ "$value" =~ ^[0-9]+$ ]]
            then
                echo "Invalid integer value for column '$column_name'"
                return
            fi
        fi

        # Primary key validation
        if [[ "$column_key" == "pk" ]]
        then
            if cut -d ":" -f1 "$data_file" | grep -w "$value" > /dev/null
            then
                echo "Primary key must be unique"
                return
            fi
        fi

        if [[ -z "$row" ]]
        then
            row="$value"
        else
            row="$row:$value"
        fi

    done 3< "$meta_file"

    echo "$row" >> "$data_file"

    echo "Row inserted successfully into '$table_name'"
}


select_from_table() {
    if [[ -z "$current_db" ]]; then
        echo "Connect to DB first"
        return
    fi

    read -p "Enter table name: " table_name

    table_path="$current_db/$table_name"
    meta_path="$current_db/$table_name.meta"

    if [[ ! -f "$table_path" ]]; then
        echo "Table does not exist"
        return
    fi

    header=""
    while IFS=: read -r col_name col_type col_key; do
        header="$header\t$col_name"
    done < "$meta_path"

    echo -e "$header"
    echo "--------------------------"

    awk -F: '{
        for(i=1;i<=NF;i++)
            printf "%-10s", $i
        printf "\n"
    }' "$table_path"
}


delete_from_table() {
    if [[ -z "$current_db" ]]; then
        echo "Connect first"
        return
    fi

    read -p "Enter table name: " table_name
    table_path="$current_db/$table_name"

    if [[ ! -f "$table_path" ]]; then
        echo "Table not found"
        return
    fi

    read -p "Enter PK: " pk

    if ! grep -q "^$pk:" "$table_path"; then
        echo "Not found"
        return
    fi

    grep -v "^$pk:" "$table_path" > tmp
    mv tmp "$table_path"

    echo "Deleted successfully"
}
