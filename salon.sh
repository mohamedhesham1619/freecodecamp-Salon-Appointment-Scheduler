#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

MAIN_MENU(){
  # if there is an argument, print it
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nChoose service\n"

  # show services
  echo "$($PSQL "SELECT * FROM services")" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # read service selection
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # show same menu if selection is not valid
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "Please choose a valid service number"
  fi

  # read phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # find customer with the phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for name and save the name and phone in customers table
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # read time
  echo -e "\nEnter appointment time"
  read SERVICE_TIME


  # add appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  exit
}

MAIN_MENU
