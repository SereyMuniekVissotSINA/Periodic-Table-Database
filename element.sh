#!/bin/bash
if [[ -z "$1" ]]; then
    echo "Please provide an element as an argument."
    exit 0
fi

DB_NAME="periodic_table"
DB_USER="postgres"

QUERY="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::text = '$1' OR e.symbol ILIKE '$1' OR e.name ILIKE '$1';"

RESULT=$(sudo -u postgres psql -d "$DB_NAME" -t -c "$QUERY" 2>/dev/null)

if [[ -z "$RESULT" ]]; then
    echo "I could not find that element in the database."
    exit 0
fi

IFS='|' read -r atomic_number symbol name atomic_mass melting_point boiling_point element_type <<< "$RESULT"

atomic_number=$(echo "$atomic_number" | xargs)
symbol=$(echo "$symbol" | xargs)
name=$(echo "$name" | xargs)
atomic_mass=$(echo "$atomic_mass" | xargs)
melting_point=$(echo "$melting_point" | xargs)
boiling_point=$(echo "$boiling_point" | xargs)
element_type=$(echo "$element_type" | xargs)

atomic_mass_formatted=$(echo "$atomic_mass" | sed 's/[0]*$//' | sed 's/\.$//')

echo "The element with atomic number $atomic_number is $name ($symbol). It's a $element_type, with a mass of $atomic_mass_formatted amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
s
