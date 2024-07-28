#!/bin/bash

DB_QUERY="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi
  
  SERVICES_LIST=$($DB_QUERY "SELECT service_id, name FROM services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SELECTED_SERVICE_ID
  case $SELECTED_SERVICE_ID in
    [1-5]) PROCESS_APPOINTMENT ;;
    *) DISPLAY_SERVICES "I could not find that service. What would you like today?" ;;
  esac
}

PROCESS_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($DB_QUERY "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/ //g')
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    SAVE_CUSTOMER=$($DB_QUERY "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  
  SERVICE_NAME=$($DB_QUERY "SELECT name FROM services WHERE service_id=$SELECTED_SERVICE_ID" | sed 's/ //g')
  CUSTOMER_ID=$($DB_QUERY "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read APPOINTMENT_TIME
  
  SAVE_APPOINTMENT=$($DB_QUERY "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SELECTED_SERVICE_ID, '$APPOINTMENT_TIME')")
  
  if [[ $SAVE_APPOINTMENT == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME at $APPOINTMENT_TIME, $CUSTOMER_NAME."
  fi
}

DISPLAY_SERVICES
