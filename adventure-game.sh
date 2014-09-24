#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
health=200
leave=false
location=start
pick=""
poisoned=false
enemy=rocket1.jpc
items={}
instr=$"Instructions:
go-to [room] takes you to the room
[1-5] corresponds to choice from prompt
exit - exits the game"
opening=$"You wake up in a large, opulent mansion.
You look around you. It looks pretty barren. There's giant R inscribed in the walls. 
You walk up to a large table in the middle of the room.
There are three Pokeballs.
What do you do?"

echo "Welcome to the Labyrinth Adventure Game!  You can leave anytime by typing [exit]"
echo "Type [help] to see instructions"
echo "Type [start] to begin!"

begin () {
    cd labyrinth/ground/
    echo "$opening"
    echo 1. Pick the red one
    echo 2. Pick the blue one
    echo 3. Pick the green one
    printf ">> "
    read choice
    case $choice in
        1) pick=charmander
            echo You picked Charmander! ;;
        2) pick=squirtle
            echo You picked Squirtle! ;;
        3) pick=bulbasaur
            echo You picked Bulbasaur! ;;
        *) echo "Please pick (1) (2) (3)" 
            begin ;;
    esac
}

prompt () {
    printf 'You are here: %s\n' "${PWD##*/}"
    echo Where do you want to go?
    for i in $(ls -d */)
    do
        echo $i 
    done
    parent=$(dirname $PWD)
    if [[ $(basename ${PWD##*/}) != "ground" ]]
        # dont show parent directory as option if on ground floor
        then echo $(basename $parent) #go back from whence you came
    fi
}

battle () {
#battle with opponent
    ehealth=40  #enemy health
    if [[ "$1" = "boss" ]]
    then
            echo "The Team Rocket boss wants to fight!"
            ehealth=80
    else echo "Team Rocket wants to fight!"
    fi
    echo "Team Rocket sends $(cat $1)!"
    echo "Go $pick!!"
    emonster=$(cat $1)
    until [[ $ehealth -le 0 || $health -le 0 ]]
    do
        echo What will you do?
        cat "$DIR/monsters/$pick.jpc"
        printf ">> "
        read choice
        case $choice in
            1) echo "It's super effective!" 
                ((ehealth-=20)) ;;
            2) echo "Critical Hit!"
                ((ehealth-=10)) ;;
            3) echo "Real men don't run from a fight!" ;;
            *) echo "Please pick (1) (2) (3)" ;;
        esac
        echo "Team Rocket used $(head -n 1 $DIR/monsters/$emonster.jpc)!"
        echo "Ouch! You lost 20 health."
        ((health-=20))
        if [[ $(( RANDOM % 2 )) -eq 0 && "$1" = "rocket2.jpc" ]]
            # 50% chance of getting poisoned from Poison Powder
            then
                poisoned=true
                echo "$pick has been poisoned! Each time you move to a new room, you will lose 10 health!"
        fi
    echo Your health: $health
    echo Enemy health: $ehealth
    if [[ $ehealth -le 0 ]]
        then echo You defeated Team Rocket!
    fi
    done
}

move () {
    if [[ $(cd $1) -eq 0 && -d $1 ]]
        then cd $1
            echo "You are now $1"
    else
        echo "Location not recognized. Please enter a valid location."
        return
    fi
    if [[ "$poisoned" = true ]]
        then
            ((health-=10))
            echo "$pick is poisoned! Your health is now $health"
            echo "You should probably find an antidote!"
    fi
    if [[ -f "rocket1.jpc"="true" ]]
        then battle rocket1.jpc
    elif [[ -e "rocket2.jpc" ]]
        then battle rocket2.jpc
    elif [[ -e "rocket3.jpc" ]]
        then battle rocket3.jpc
    elif [[ -e "boss.jpc" ]]
        then battle boss.jpc
    fi
    echo $1
}

#Main game loop
while [[ $health -gt 0 && $leave != true ]]
do
    printf ">> "
    read cmd location
    if [[ "$cmd" = "exit" ]]
        #exit the game
        then leave=true
    elif [[ "$cmd" = "start" ]]
        then started=1 
            begin 
    elif [[ "$cmd" = "help" ]]
        then echo "$instr"
    elif [[ "$cmd" = "go-to" ]]
        #move to different location
        then move $location
    else
        echo "Sorry, command not recognized. To move to a different room, type: go-to [room]"
    fi
    if [ $started -eq 1 ]
        then prompt
    fi
done



if [[ $health -eq 0 ]]
    then echo "You're dead! Better luck next time!"
fi 
echo "Bye!"
