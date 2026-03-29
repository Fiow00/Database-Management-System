#!/bin/bash

table_menu() {
    PS3="Choose a table option: "

    options=("Create Table" "List Tables" "Drop Table" "Insert" "Select" "Update" "Delete" "Back")

    select choice in "${options[@]}"
    do
        case $choice in
            "Create Table") create_table ;;
            "List Tables") list_tables ;;
            "Drop Table") drop_table ;;
            "Insert") insert_into_table ;;
            "Select") select_from_table ;;
            "Update") update_table      ;;
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

update_table() {
    if [[ -z "$current_db" ]]; then
        echo "Connect to DB first"
        return
    fi

    read -p "Enter table name: " table_name

    table_path="$current_db/$table_name"
    meta_path="$current_db/$table_name.meta"

    if [[ ! -f "$table_path" ]]; then
        echo "Table not found"
        return
    fi

    read -p "Enter primary key value: " pk
    if ! grep -q "^$pk:" "$table_path"; then
        echo "Record not found"
        return
    fi

    
    echo "Columns:"
    col_num=1
    declare -a col_names
    declare -a col_types

    while IFS=: read -r col_name col_type col_key; do
        echo "$col_num) $col_name ($col_type)"
        col_names[$col_num]="$col_name"
        col_types[$col_num]="$col_type"
        ((col_num++))
    done < "$meta_path"

    read -p "Choose column number: " choice

    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ -z "${col_names[$choice]}" ]]; then
        echo "Invalid choice"
        return
    fi

    read -p "Enter new value: " new_value

   
    if [[ "${col_types[$choice]}" == "int" && ! "$new_value" =~ ^[0-9]+$ ]]; then
        echo "Invalid int value"
        return
    fi

   
    if [[ "$choice" -eq 1 ]]; then
        if grep -q "^$new_value:" "$table_path"; then
            echo "Primary key must be unique"
            return
        fi
    fi


    awk -F: -v pk="$pk" -v col="$choice" -v val="$new_value" 'BEGIN{OFS=":"}
    {
        if ($1 == pk) {
            $col = val
        }
        print
    }' "$table_path" > tmp

    mv tmp "$table_path"

    echo "Updated successfully"
}

list_tables() {
    # Check if connected to a database
    if [[ -z "$current_db" ]]; then
        echo "You must connect to a database first"
        return
    fi

    # Check if there are any tables in the database
    table_count=$(ls "$current_db" 2>/dev/null | grep -v "\.meta$" | wc -l)
    
    if [[ $table_count -eq 0 ]]; then
        echo "No tables found in this database"
    else
        echo "Tables in database:"
        ls "$current_db" | grep -v "\.meta$"
    fi
}

drop_table() {
    # Check if connected to a database
    if [[ -z "$current_db" ]]; then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name to drop: " table_name

    # Check if table name is empty
    if [[ -z "$table_name" ]]; then
        echo "Table name cannot be empty"
        return
    fi

    table_path="$current_db/$table_name"
    meta_path="$current_db/$table_name.meta"

    # Check if table exists
    if [[ ! -f "$table_path" ]]; then
        echo "Table '$table_name' does not exist"
        return
    fi

    # Delete both table data file and metadata file
    rm "$table_path"
    rm "$meta_path" 2>/dev/null

    echo "Table '$table_name' dropped successfully"
}