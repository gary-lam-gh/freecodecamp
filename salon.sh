#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  # Display 1st arguement
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # Retrieve services in DB
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services WHERE service_id <> 10 ORDER BY service_id")
  if [[ -z $LIST_OF_SERVICES ]]
  then
    echo "Welcome to My Salon, no service available, sorry for inconvenience caused."
  
  else
    echo "Welcome to My Salon, how can I help you?"
    echo -e "$LIST_OF_SERVICES" | while IFS='|'  read SERVICE_ID NAME
    do
      #echo "$SERVICE_ID) $NAME" 
      ID=$(echo $SERVICE_ID | sed 's/ //g')
      SERVICE_NAME=$(echo $NAME | sed 's/ //g')
      echo "$ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED
    
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That is not a valid number. Please choice a valid service id:"
    else
      # Check if service exists
      SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_EXISTS ]]
      then
        MAIN_MENU "\nI could not find that service. What would you like today?"
      else
        # Get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        #echo -e "$CUSTOMER_DETAILS" | while IFS='|' read CUSTOMER_ID CUSTOMER_PHONE CUSTOMER_NAME
          # if not found
          if [[ -z "$CUSTOMER_ID" ]]
          then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            # Insert new customer to db
            INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            # Get customer id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          else
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
            #echo "Welcome back $CUSTOMER_NAME"
          fi

          # Get the service name
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          # Get the service time
          echo -e "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME

          # Insert new appointment to db 
          #echo "Cusomer ID: $CUSTOMER_ID"
          APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
  fi

  SERVICE_COUNT=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id IS NOT NULL")
  #read SERVICE_ID_SELECTED
  #echo "Test - $SERVICE_COUNT"
  # Display main service menu
  ##echo "Welcome to My Salon, how can I help you?"
  ##echo -e "\n1. Cut\n2. Colouring\n3. Exit"
  # Read selection and redirect to sub-menu
  ##read SERVICE_SELECTION
  ##case $SERVICE_SELECTION in
  ##  1) CUT_MENU ;;
  ##  2) COLOURING_MENU ;;
  ##  3) EXIT ;;
  ##  *) MAIN_MENU "Please enter a valid option.";;
  ##esac

}


CUT_MENU(){
  echo "Cut Menu"
}

COLOURING_MENU(){
  echo "Colouring Menu"
}

EXIT(){
  echo "Exit"
}
MAIN_MENU