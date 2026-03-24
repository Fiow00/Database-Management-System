#! /bin/bash
table_menu() {
    PS3="Choose a table option: "

    options=("Create Table" "List Tables" "Drop Table" "Insert" "Select" "Update" "Delete" "Back")

    select choice in "${options[@]}"
    do
        case $choice in
            "Create Table")
                echo "Create Table selected"
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
                echo "Select selected"
                ;;
            "Update")
                echo "Update selected"
                ;;
            "Delete")
                echo "Delete selected"
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
