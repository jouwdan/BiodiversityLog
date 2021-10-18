#!/bin/bash

quit() { echo "Thanks for visiting the biodiversity log."; exit 0; }
fail() { echo "Invalid option." exit 1; }
​
menu() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please choose from one of the following options:    |"
  echo "|                                                       |"
  echo "|   1) Add a new Recording of a Species                 |"
  echo "|   2) Remove an existing Species Record                |"
  echo "|   3) Search for Species                               |"
  echo "|   4) E-mail Recorder(s)                               |"
  echo "|   0) Quit                                             |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter your selection: "
  read -r input
  case $input in
    1)
      addRecord
      menu
      ;;
    2)
      remove
      menu
      ;;
    3)
      searchSpecies
      menu
      ;;
    4)
      emailRecorders
      menu
      ;;
    0)
      quit
      ;;
    *)
      fail
      ;;
  esac
}
​
addRecord() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please add your recording below.                    |"
  echo "|*******************************************************|"
  echo -n "Please enter the species Name: "
  read -r speciesName
  echo -n "Please enter the Eircode of the location: "
  read -r speciesEircode
  # Eircode regex from https://stackoverflow.com/questions/33391412/validation-for-irish-eircode
  while [[ ! $speciesEircode =~ ^[ACDEFHKNPRTVWXY]{1}[0-9]{1}[0-9W]{1}[\ \-]?[0-9ACDEFHKNPRTVWXY]{4}$ ]];
  do
    echo -n "Not a valid Eircode, please try again: "
    read -r speciesEircode
  done
  echo -n "Please enter the date the species was recorded (DD/MM/YYYY): "
  read -r dateRecorded
  while [[ ! $dateRecorded =~ ^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$ ]];
  do
    echo -n "Not a valid Date, please try again: "
    read -r dateRecorded
  done
  echo -n "Please enter your email address: "
  read -r emailAddress
  while [[ ! $emailAddress =~ ^[a-zA-Z0-9]{1,}\@[a-zA-Z0-9]{1,}\.[a-zA-Z]{1,}$ ]];
  do
    echo -n "Not a valid Email, please try again: "
    read -r emailAddress
  done
​  # write the input details as comma separated values to the speciesDetails file
  echo "$speciesName,$speciesEircode,$dateRecorded,$emailAddress" >> speciesDetails
  read -p "Recording successfully saved! Press enter to go back to the main menu."
}
​
remove() { 
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please choose from one of the following options:    |"
  echo "|                                                       |"
  echo "|   1) Remove all recordings                            |"
  echo "|   2) Remove a specific recording                      |"
  echo "|   0) Back to main menu                                |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter your selection: "
  read -r input
  case $input in
    1)
      removeall
      remove
      menu
      ;;
    2)
      removeSpecific
      remove
      menu
      ;;
    0)
      menu
      ;;
    *)
      fail
      ;;
  esac
}

removeall() { 
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Are you sure you want to delete ALL entries?        |"
  echo "|                                                       |"
  echo "|   1) Yes                                              |"
  echo "|   2) No                                               |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter your selection: "
  read -r input
  case $input in
    1)
      actuallyRemoveAll
      menu
      ;;
    2)
      menu
      ;;
    *)
      fail
      ;;
  esac
}

actuallyRemoveAll() {
  clear
  echo "|*******************************************************|"
  echo "|   Creating backup ...                                 |"
  echo "|*******************************************************|"
  # copy the current data in speciesDetails to a new file speciesDetails.bak
  cp speciesDetails speciesDetails.bak
  sleep 3
  clear
  echo "|*******************************************************|"
  echo "|   Purging Entries ...                                 |"
  echo "|*******************************************************|"
  # delete the data in the speciesDetails file
  truncate -s 0 speciesDetails
  sleep 3
  clear
  echo "|*******************************************************|"
  echo "|   Complete!                                           |"
  echo "|*******************************************************|"
  sleep 3
}

removeSpecific() { 
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   What would you like to remove?                      |"
  echo "|                                                       |"
  echo "|   1) Entries by Species                               |"
  echo "|   2) Entries by Location                              |"
  echo "|   3) Entries by Date                                  |"  
  echo "|   4) Entries by Email                                 |"
  echo "|   0) Back to menu                                     |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter your selection: "
  read -r input
  case $input in
    1)
      removeEntryBySpecies
      menu
      ;;
    2)
      removeEntryByLocation
      menu
      ;;
    3)
      removeEntryByDate
      menu
      ;;
    4)
      removeEntryByEmail
      menu
      ;;
    0)
      menu
      ;;
    *)
      fail
      ;;
  esac
}

removeEntryBySpecies() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please enter the species you would like to remove   |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter the species: "
  read -r input
  countSpecies=$(cut -f 1 -d , speciesDetails | grep -ic $input)
  echo "Removing $countSpecies instances of $input..."
  sleep 3
  # create a new temp file without the rows & replace old file with temp file
  awk -F, -v input="$input" '{if ($1 != input) print}' speciesDetails > speciesDetailsTmp && mv speciesDetailsTmp speciesDetails
  # wait until enter key is pressed before going back to menu
  read -n 1 -p "Done! Press enter to go back to the main menu."
}

removeEntryByLocation() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please enter the eircode you would like to remove   |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter the eircode: "
  read -r input
  countEircode=$(cut -f 2 -d , speciesDetails | grep -ic $input)
  echo "Removing $countEircode instances of $input..."
  sleep 3
  # create a new temp file without the rows & replace old file with temp file
  awk -F, -v input="$input" '{if ($2 != input) print}' speciesDetails > speciesDetailsTmp && mv speciesDetailsTmp speciesDetails
  # wait until enter key is pressed before going back to menu
  read -n 1 -p "Done! Press enter to go back to the main menu."
}

removeEntryByDate() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please enter the date you would like to remove      |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter the date (DD/MM/YYYY): "
  read -r input
  countDate=$(cut -f 3 -d , speciesDetails | grep -ic $input)
  echo "Removing $countDate instances of $input..."
  sleep 3
  # create a new temp file without the rows & replace old file with temp file
  awk -F, -v input="$input" '{if ($3 != input) print}' speciesDetails > speciesDetailsTmp && mv speciesDetailsTmp speciesDetails
  # wait until enter key is pressed before going back to menu
  read -n 1 -p "Done! Press enter to go back to the main menu."
}

removeEntryByEmail() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please enter the email you would like to remove     |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter the email: "
  read -r input
  countEmail=$(cut -f 4 -d , speciesDetails | grep -ic $input)
  echo "Removing $countEmail instances of $input..."
  sleep 3
  # create a new temp file without the rows & replace old file with temp file
  awk -F, -v input="$input" '{if ($3 != input) print}' speciesDetails > speciesDetailsTmp && mv speciesDetailsTmp speciesDetails
  # wait until enter key is pressed before going back to menu
  read -n 1 -p "Done! Press enter to go back to the main menu."
}

searchSpecies() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Please enter the species you would like to find     |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter the species: "  
  read -r species
  echo ""
  # count the number of rows containing the species
  count=$(cut -f 1 -d , speciesDetails | grep -ic -w "$species")
  echo "found $count instance(s) of $species"
  # print each row which contains the species in the first column
  awk -F, -v species="$species" '$1 == species {print "Name: " $1 " Location: " $2 " Date: " $3}' speciesDetails
  echo ""
  # wait until enter key is pressed before going back to menu
  read -n 1 -p "Press enter to go back to the main menu."
}

emailRecorders() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|   Who would you like to email?                        |"
  echo "|                                                       |"
  echo "|   1) All Recorders                                    |"
  echo "|   2) Recorders by species                             |"
  echo "|   3) Recorders by Location                            |"  
  echo "|   4) Recorders by Date                                |"
  echo "|   0) Back to menu                                     |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter your selection: "
  read -r input
  case $input in
    1)
      emailAllRecorders
      menu
      ;;
    2)
      emailRecordersBySpecies
      menu
      ;;
    3)
      emailRecordersByLocation
      menu
      ;;
    4)
      EmailRecordersByDate
      menu
      ;;
    0)
      menu
      ;;
    *)
      fail
      ;;
  esac
}

emailAllRecorders() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter email body: "  
  read -r emailBody
  emailList=$(awk -F, '{printf $4","}' speciesDetails)
  mail -s 'message from the Biodiversity Log' $emailList <<< '$emailBody'
  read -n 1 -p "Success! Press enter to go back to the main menu."
}

emailRecordersBySpecies() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter species loggers you would like to email: "  
  read -r species
  emailList=$(awk -F, -v species="$species" '$1 == species {printf $4","}' speciesDetails)
  echo -n "Please enter email body: "  
  read -r emailBody
  mail -s 'message from the Biodiversity Log' $emailList <<< '$emailBody'
  read -n 1 -p "Succces! Press enter to go back to the main menu."
}

emailRecordersByLocation() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter eircode of the location you would like to email: "  
  read -r eircode
  emailList=$(awk -F, -v eircode="$eircode" '$2 == eircode {printf $4","}' speciesDetails)
  echo -n "Please enter email body: "  
  read -r emailBody
  mail -s 'message from the Biodiversity Log' $emailList <<< '$emailBody'
  read -n 1 -p "Success! Press enter to go back to the main menu."
}

emailRecordersByDate() {
  clear
  echo "|*******************************************************|"
  echo "|   Welcome to the biodiversity log.                    |"
  echo "|*******************************************************|"
  echo ""
  echo -n "Please enter date you would like to email (DD/MM/YYYY): "  
  read -r dateInput
  emailList=$(awk -F, -v dateInput="$dateInput" '$3 == dateInput {printf $4","}' speciesDetails)
  echo -n "Please enter email body: "  
  read -r emailBody
  mail -s 'message from the Biodiversity Log' $emailList <<< '$emailBody'
  read -n 1 -p "Success! Press enter to go back to the main menu."
}
​
menu