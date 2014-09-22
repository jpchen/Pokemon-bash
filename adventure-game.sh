#!/bin/bash
health=100
leave=false
echo "Welcome to the Labyrinth Adventure Game!  You can leave anytime by typing [exit]"
while [[ $health -gt 0 && $leave != true ]]
do
    read cmd
    if [[ "$cmd" = "exit" ]]
        then leave=true
    elif [[ "$cmd" = "0" ]]
        then health=0
    fi
done
if [[ $health -eq 0 ]]
then echo "You're dead! Better luck next time sucker!"
fi 
echo "Bye!"
