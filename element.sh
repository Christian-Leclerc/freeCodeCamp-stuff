#! /bin/bash
#  ~~~ Periodic Table Database ~~~
PSQL="psql -U freecodecamp -d periodic_table -t --no-align -c"

FIND_ELEMENT() {

  ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE $2='$1'")

}

#is there an argument
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #validate type of argument
  if [[ $1 =~ ^[0-9]+$ ]]
  then
      FIND_ELEMENT $1 atomic_number
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
      FIND_ELEMENT $1 symbol
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
      FIND_ELEMENT $1 name
  else
      ELEMENT=""
  fi
  #search argument
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
    exit 0
  else
  #print information about element
    echo $ELEMENT | while IFS='|' read ATOMIC SYMBOL NAME
    do
      INFO=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types ON properties.type_id=types.type_id WHERE atomic_number=$ATOMIC")
      echo $INFO | while IFS='|' read MASS MELT BOIL TYPE
      do
        echo "The element with atomic number $ATOMIC is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
      done
    done
  fi
fi
exit 0
