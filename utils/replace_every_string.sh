#!/bin/bash
# WARNING: THIS SCRIPT IS WRITTEN BY A COMPLETE NOOB IN BASH!!!

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
	echo "Usage: ./script.sh <initial_string> <new_string>"
	exit 1
fi

initial_string=$1
new_string=$2

modified_files=0
modified_lines=0

# ANSI escape code for bold
bold=$(tput bold)
green=$(tput setaf 2)
normal=$(tput sgr0)

# Find and replace strings in files
while read file
do
	echo "----------------------------------------"
	echo "Modifying $file"
	echo "Modified lines:"
	grep -n "\"$initial_string\"" "$file" | sed "s/\"$initial_string\"/${bold}${green}\"$initial_string\"${normal}/g"
	lines=$(grep -n "\"$initial_string\"" "$file" | wc -l)

	sed -i "s/\"$initial_string\"/\"$new_string\"/g" "$file"

	modified_lines=$((modified_lines + lines))
	modified_files=$((modified_files + 1))
done < <(find . -type f -exec grep -l "\"$initial_string\"" {} \;)

echo "----------------------------------------"
echo "Total modified files: $modified_files"
echo "Total modified lines: $modified_lines"
