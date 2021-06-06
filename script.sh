#!/bin/bash

clear

echo "Searching for latest exports in your Downloads folder..."
echo ""
FILESFOUND="/tmp/filesfound.txt"
echo -n >$FILESFOUND
if [ `find ~/Downloads/ -name "*.enex" | wc -l` -gt 0 ] ; then

ls -d ~/Downloads/*.enex >$FILESFOUND 

fi

if [ -s $FILESFOUND ]; then
  echo "Please type the NUMBER of the file you wish to use and hit ENTER:"
  echo ""
  cat -n $FILESFOUND
  read SELECTION
  theExportFile=$(sed -n ${SELECTION}p $FILESFOUND)
  echo ""
  echo "Great choice!"
  echo ""
  echo "You picked: $theExportFile "
  printf "Doing cool things....."

  FILE=$theExportFile
  TEMPORARY="/tmp/holding.txt"
  grep -o '<title.*title>\|^--.*' $FILE | sed -e s/\<title\>//g | sed -e s/\<\\/title\>//g >$TEMPORARY
  
  NOW=$(date +"%m-%d-%Y_%k-%M-%S")

  OUTPUTFILE=~/Desktop/output_$NOW.csv

  echo "Request ID List" > $OUTPUTFILE

  cat $TEMPORARY |
    while IFS=$'\n' read -r line; do
      echo $line | grep -o 'Request ID#:\d\+' >>$OUTPUTFILE
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
  echo -ne "\n\n"
  echo "We are all done!"
  echo "I put the file on your Desktop."
  echo "See $OUTPUTFILE"
  echo ""
  echo "It has a total of $(cat $OUTPUTFILE | grep "Request ID#:" -c) entries."
  echo ""
  echo "I hope you have an awesome day!"

else

  echo "Uh oh, looks like you didn't export a notebook yet."
  echo "Please see www------ to find out how to do this"
  echo "             ^^^^ (cmd + click on that url)"
  echo ""

fi

counter=10
echo "This screen will self-destruct in $counter seconds!"
until [ $counter -lt 1 ]; do
  printf "$counter..."
  sleep 1
  ((counter--))
done
printf "Bye!"
