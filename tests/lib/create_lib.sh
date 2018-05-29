#!/bin/bash 

create_file (){
    local new_file=$1
    sudo rm $new_file
    if touch $new_file > /dev/null 2>&1; then
        : > $new_file
        echo "File $new_file successfully created"
    else
        echo "Error. Can't create $new_file"
        exit 1
    fi
}

create_dir (){
    local new_dir=$1
    sudo rm $new_dir -r
    if mkdir $new_dir > /dev/null 2>&1; then
        : > $new_dir
        echo "Directory $new_dir successfully created"
    else
        echo "Error. Can't create $new_dir"
        exit 1
    fi
}


