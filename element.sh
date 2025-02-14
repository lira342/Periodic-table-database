#!/bin/bash

# Check if input is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0  # Use exit 0 to cleanly terminate without errors
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Determine if input is an atomic number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY_CONDITION="atomic_number = $1"
elif [[ ${#1} -le 2 ]]; then
  QUERY_CONDITION="symbol = '$1'"
else
  QUERY_CONDITION="name = '$1'"
fi

# Fetch element details
DATA=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
              FROM elements 
              INNER JOIN properties USING(atomic_number) 
              INNER JOIN types USING(type_id) 
              WHERE $QUERY_CONDITION;")

# Check if data exists
if [[ -z $DATA ]]; then
  echo "I could not find that element in the database."
else
  echo "$DATA" | while IFS=" |" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING; do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
