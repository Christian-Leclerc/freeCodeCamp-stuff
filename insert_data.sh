#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear tables
echo $($PSQL "TRUNCATE games, teams")

#Read all data except first line, insert in tables in order
cat games.csv | while IFS="," read YEAR ROUND WIN OPP WGOAL OPPGOAL
do
  if [[ $YEAR != "year" ]]
  then
    #get winner id
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    #if not found
    if [[ -z $WIN_ID ]]
    then
      # insert winner in teams
      echo $($PSQL "INSERT INTO teams(name) VALUES('$WIN')")
      #get new winner id
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    fi
    #get opponent id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    #if not found
    if [[ -z $OPP_ID ]]
    then
      #insert opponent in teams
      echo $($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
      #get new opponent id
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    fi
    #insert into games
    echo $($PSQL "INSERT INTO games(round, winner_id, opponent_id, winner_goals, opponent_goals, year) VALUES('$ROUND', $WIN_ID, $OPP_ID, $WGOAL, $OPPGOAL, $YEAR)")
  fi
done