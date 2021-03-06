#!/bin/bash

clear

echo "Searching for latest exports in your Downloads folder..."
echo ""
FILESFOUND="/tmp/filesfound.txt"
echo -n >$FILESFOUND
if [ $(find ~/Downloads/ -name "*.enex" | wc -l) -gt 0 ]; then

  ls -d ~/Downloads/*.enex >$FILESFOUND

fi

if [ -s $FILESFOUND ]; then
  echo "Please type the NUMBER of the file you wish to use and hit ENTER:"
  echo ""
  cat -n $FILESFOUND
  read SELECTION
  theExportFile=$(sed -n ${SELECTION}p $FILESFOUND)
  echo ""
  echo "You picked: $theExportFile "

  #check that the file has no spaces
  hasSpaces=$(echo "$theExportFile" | grep " " -c)
  if [ $hasSpaces -gt 0 ]; then

    echo "Oh dear, we can't use a filename with a space in it."
    echo "Would you mind changing the filename to have no spaces?"
    echo ""
    echo "Once you do that, you can come back and try again."
    echo ""

    ###
    counter=10
    echo "This screen will close in $counter seconds!"
    until [ $counter -lt 1 ]; do
      printf "$counter..."
      sleep 1
      ((counter--))
    done
    printf "Bye!"
  ###

  fi

  echo ""
  echo "Great choice!"

  printf "Doing cool things....."

  # FILE=$(echo "$theExportFile" | sed 's! !\\ !g')
  FILE=$theExportFile
  # echo $FILE
  TEMPORARY="/tmp/holding.txt"
  tr '\n' ' ' <$FILE | sed 's/\<\/title\>/\<\/title\>\'$'\n/g' | grep -o "<title.*title>\|^--.*" | sed -e s/\<title\>//g | sed -e s/\<\\/title\>//g >$TEMPORARY

  NOW=$(date +"%-m-%-d-%-Y_%-k-%-M-%-S")
  OUTPUTFILE=~/Desktop/output_$NOW.csv
  # echo $OUTPUTFILE
  # echo "Request ID List" >$OUTPUTFILE
  echo -n >$OUTPUTFILE

  cat $TEMPORARY |
    while IFS=$'\n' read -r line; do
      ##and now we'll need to remove the request id after we grep it
      # |  sed -e s/"Request ID#:"//g
      echo $line | grep -o 'Request ID#:\d\+' | sed -e s/"Request ID#:"//g >>$OUTPUTFILE
    done

  printf "..." && sleep 1

  printf "\nLooking for duplicates..."
  dupeCount=$(sort $OUTPUTFILE | uniq -d | wc -l)

  printf "..." && sleep 1

  if [ $dupeCount -gt 0 ]; then
    echo ""
    echo "   Uh oh, looks like we found some duplicates."
    printf "   We should clean those up..."
    sort -u $OUTPUTFILE -o $OUTPUTFILE
    sleep 1

    printf "..."
    echo "   Awesome, all cleaned up."
  else
    echo "   Cool, no duplicate entries found."
  fi
  totalCount=$(cat $OUTPUTFILE | wc -l)
  echo "Adding a header to the csv"

  echo -e "Request_ID_List\n$(cat $OUTPUTFILE)" >$OUTPUTFILE

  echo -ne "\n\n"
  echo "We are all done!"
  echo "I put the file on your Desktop."
  echo "See $OUTPUTFILE"
  echo ""
  echo "It has a total of $totalCount entries."
  echo ""
  echo "I hope you have an awesome day!"

  ###
  counter=10
  echo "This screen will close in $counter seconds!"
  until [ $counter -lt 1 ]; do
    printf "$counter..."
    sleep 1
    ((counter--))
  done
  printf "Bye!"
###

else

  echo "Uh oh, looks like you didn't export a notebook yet."
  echo "Please see https://github.com/thehandsomezebra/Request_ID_Helper to find out how to do this"
  echo "             ^^^^ (cmd + click on that url)"
  echo ""

  ###
  counter=10
  echo "This screen will close in $counter seconds!"
  until [ $counter -lt 1 ]; do
    printf "$counter..."
    sleep 1
    ((counter--))
  done
  printf "Bye!"
###

fi
