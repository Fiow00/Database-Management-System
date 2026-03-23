# Bash Shell Script DBMS

## Project Description
This project is a **Database Management System (DBMS)** fully implemented using **Bash scripting**.
The application allows users to create databases and tables, insert, update, delete, and retrieve data.
All operations are performed through a **Command Line Interface (CLI)**.

## Features

### Main Menu
- Create Databas
- List Databases
- Connect to Database
- Drop Database 

### Database Menu (after connecting to a database)
- Create Table (with column names and data types)
- List Tables
- Drop Table
- Insert into Table (with data type validation) 
- Select From Table (display formatted output)
- Update Table (with data type validation)
- Delete From Table 

## Project Structure & Implementation
- Databases are stored as directories in the script’s working directory.
- Tables are stored as files within the corresponding database directory.
- Data is stored in text files with columns separated by a delimiter (e.g., `:`).
- Input validation ensures correct data types for each column.
- `awk` and `sed` are used for data processing and formatting.
- Bash functions are used for reusable operations (e.g., input validation, formatting output).

---

## Team Members & Responsibilities

| Member   | Responsibilities |
|----------|-----------------|
| Ahmed    | Create, List, Connect, and Drop Databases. Handle directory structure and main menu navigation. |
| Mostafa  | Create, List, Drop Tables. Implement Insert, Select, Update, Delete operations. Handle data validation and formatting. |
| Both     | Shared helper functions, testing, and integration. |

## References
- https://www.youtube.com/watch?v=x5B6p7JoNwE
- https://www.youtube.com/watch?v=zfPFzhoIKnU
- https://linuxsimply.com/bash-scripting-tutorial/variables/types/ps3/
- https://medium.com/@gudisagebi1/conditions-in-bash-scripting-if-statements-94e883a8d493
