#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
else
    element=$1
    if [[ $element =~ ^[0-9]+$ ]]; then
      # Run the PostgreSQL query and capture the output
      result=$(psql -U freecodecamp -d periodic_table -t -c \
          "SELECT atomic_number, name, symbol FROM elements WHERE atomic_number = $element;")
    else
      result=$(psql -U freecodecamp -d periodic_table -t -c \
          "SELECT atomic_number, name, symbol FROM elements WHERE symbol = '$element' OR name = '$element';")
    fi

    # Check if the result is not empty (element found)
    if [ -n "$result" ]; then
        # Use read to assign values to variables
        IFS='|' read -r atomic_number name symbol <<< "$result"

        # Trim leading and trailing spaces from variables if needed
        atomic_number=$(echo "$atomic_number" | tr -d '[:space:]')
        name=$(echo "$name" | tr -d '[:space:]')
        symbol=$(echo "$symbol" | tr -d '[:space:]')

        result_properties=$(psql -U freecodecamp -d periodic_table -t -c \
        "select atomic_mass, melting_point_celsius, boiling_point_celsius, type_id from properties where atomic_number=$atomic_number;")
        IFS='|' read -r atomic_mass melting_point_celsius boiling_point_celsius type_id <<< "$result_properties"

        atomic_mass=$(echo "$atomic_mass" | tr -d '[:space:]')
        melting_point_celsius=$(echo "$melting_point_celsius" | tr -d '[:space:]')
        boiling_point_celsius=$(echo "$boiling_point_celsius" | tr -d '[:space:]')
        type_id=$(echo "$type_id" | tr -d '[:space:]')

        result_types=$(psql -U freecodecamp -d periodic_table -t -c \
        "select type from types where type_id=$type_id;")

        IFS='|' read -r type <<< "$result_types"
        type=$(echo "$type" | tr -d '[:space:]')


        # Print the values
        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
    else
        echo "I could not find that element in the database."
    fi
fi
