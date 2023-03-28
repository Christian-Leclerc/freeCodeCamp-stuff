#! /bin/bash
# My Salon appointments machine

PSQL="psql -X -U freecodecamp -d salon -t -c"

echo -e "\n~~~~~ My SALON~~~~~\n"
#show choices
MAIN_MENU() {

    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
    do
        echo -e "$SERVICE_ID) $SERVICE"
    done

    GET_CHOICE
}

GET_CHOICE() {
#service choice
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        #echo "pas un chiffre"
        MAIN_MENU "I could not found this service. How may I help you?"
    else
        SELECTION=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        if [[ -z $SELECTION ]]
        then
            #echo "pas connu"
            MAIN_MENU "I could not found this service. How may I help you?"
        fi
    fi
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
#phone check
    echo -e "\nWhat is you phone number?"
    read CUSTOMER_PHONE
    PHONE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $PHONE ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        #create new customer
        RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
    #get customer name if already exits
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
#get ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
#get hours
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    exit
}
MAIN_MENU "Welcome to My Salon! How may I help you?"