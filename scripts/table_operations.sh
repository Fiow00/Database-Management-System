#! /bin/bash
table_menu() {
    PS3="Choose a table option: "

    options=("Create Table" "List Tables" "Drop Table" "Insert" "Select" "Update" "Delete" "Back")

    select choice in "${options[@]}"
    do
        case $choice in
            "Create Table")
                create_table
                ;;
            "List Tables")
                echo "List Tables selected"
                ;;
            "Drop Table")
                echo "Drop Table selected"
                ;;
            "Insert")
                echo "Insert selected"
                ;;
            "Select")
                select_from_table
                ;;
            "Update")
                echo "Update selected"
                ;;
            "Delete")
                delete_from_table
                ;;
            "Back")
                break
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
}



create_table() {
   
    if [[ -z "$current_db" ]]
    then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name: " table_name

    
    if [[ -z "$table_name" ]]
    then
        echo "Table name cannot be empty"
        return
    fi

    
    if [[ -f "$current_db/$table_name" ]]
    then
        echo "Table already exists"
        return
    fi

    read -p "Enter number of columns: " cols_num

    
    if ! [[ "$cols_num" =~ ^[0-9]+$ ]]
    then
        echo "Invalid number"
        return
    fi

    meta_file="$current_db/$table_name.meta"
    data_file="$current_db/$table_name"

    > "$meta_file"   
    > "$data_file"   

    for ((i=1; i<=cols_num; i++))
    do
        echo "Column $i:"

        read -p "  Name: " col_name
        read -p "  Type (int/string): " col_type

        
        if [[ "$col_type" != "int" && "$col_type" != "string" ]]
        then
            echo "Invalid type, defaulting to string"
            col_type="string"
        fi

        
        if [[ $i -eq 1 ]]
        then
            echo "$col_name:$col_type:pk" >> "$meta_file"
        else
            echo "$col_name:$col_type" >> "$meta_file"
        fi
    done

    echo "Table '$table_name' created successfully"
}


select_from_table() {
   
    if [[ -z "$current_db" ]]
    then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name: " table_name

    table_path="$current_db/$table_name"
    meta_path="$current_db/$table_name.meta"

   
    if [[ ! -f "$table_path" ]]
    then
        echo "Table does not exist"
        return
    fi

    
    header=""

    while IFS=: read -r col_name col_type col_key
    do
        header="$header\t$col_name"
    done < "$meta_path"

    echo -e "$header"
    echo "----------------------------------"

   
    awk -F: '{
        for(i=1; i<=NF; i++) {
            printf "%-10s", $i
        }
        printf "\n"
    }' "$table_path"
}

delete_from_table() {
    
    if [[ -z "$current_db" ]]
    then
        echo "You must connect to a database first"
        return
    fi

    read -p "Enter table name: " table_name

    table_path="$current_db/$table_name"

    
    if [[ ! -f "$table_path" ]]
    then
        echo "Table does not exist"
        return
    fi

    read -p "Enter primary key value to delete: " pk_value

   
    if [[ -z "$pk_value" ]]
    then
        echo "Primary key cannot be empty"
        return
    fi

   
    if ! grep -q "^$pk_value:" "$table_path"
    then
        echo "Record not found"
        return
    fi

    
    grep -v "^$pk_value:" "$table_path" > temp_file
    mv temp_file "$table_path"

    echo "Record deleted successfully"
}