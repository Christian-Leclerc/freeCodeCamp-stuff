#! /bin/bash
# Guessing number game

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

echo -e "\nWelcome to the number guessing game\n"

MENU() {
  #asking username
  echo "Enter your username:"
  read USER_NAME
  #verifying username 
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
  if [[ -z $USER_ID ]]
  then
    #New username
    echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here.\n"
    RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
    #Retrieve new user_id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
    PLAY $USER_ID
  else
    #Retrieve data from username
    PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
    GUESSES=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
    echo -e "\nWelcome back, $USER_NAME! You have played $PLAYED games, and your best game took $GUESSES guesses.\n"
    PLAY $USER_ID
  fi
}
PLAY () {
  #$1 = USER_ID
  echo "Guess the secret number between 1 and 1000:"
  read ANSWER
  SECRET=$(( $RANDOM % 1000 + 1))
  GUESSES=0
  while [ $ANSWER != $SECRET ]
  do
    if [[ ! $ANSWER =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
        read ANSWER
      else
        if [[ $ANSWER -lt $SECRET ]]
        then
          echo "It's higher than that, guess again:"
          ((GUESSES++))
          read ANSWER
        else
          echo "It's lower than that, guess again:"
          ((GUESSES++))
          read ANSWER
        fi
    fi
  done
  ((GUESSES++))
  RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($1, $GUESSES)")
  echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
}
MENU
exit 0