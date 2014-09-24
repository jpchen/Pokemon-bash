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
win=$"
You have defeated the great Giovanni
All of the Pokemon world has you to thank.
Horray!!
"


cat "$DIR/img/pokemonlogo.jpc"
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
    if [[ "$(ls -d $PWD)" ]] 
        then for i in $(ls -d */)
        do
            echo $i 
        done
    fi
    parent=$(dirname $PWD)
    if [[ $(basename ${PWD##*/}) != "ground" ]]
        # dont show parent directory as option if on ground floor
        then echo $(basename $parent) #go back from whence you came
    fi
}

win () {
    echo "Giovani: Hahaha nice try! You have defeated me this time, but I will be back!"
    sleep 1
    echo "Huh where did he go??"
    sleep 1
    echo ...
    sleep 1
    echo "Well at least I got rid of him and saved the world. Mom would be proud!"
    sleep 1
    cat "$DIR/img/congrats.jpc"
    echo $winmessage
    sleep 1
    cat "$DIR/img/pikachu.jpc"
    sleep 1
    cat "$DIR/img/bulb.jpc"
    sleep 1
    cat "$DIR/img/squirtle.jpc"
    sleep 1
    cat "$DIR/img/charizard.jpc"
    exit
}

battle () {
#battle with opponent
    ehealth=40  #enemy health
    if [[ "$1" = "boss.jpc" ]]
    then
            echo "The Team Rocket boss wants to fight!"
            ehealth=80
    else echo "Team Rocket wants to fight!"
    fi
    sleep 1
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
        sleep 1
        echo "Ouch! You lost 20 health."
        ((health-=20))
        if [[ $(( RANDOM % 2 )) -eq 0 && "$1" = "rocket2.jpc" ]]
            # 50% chance of getting poisoned from Poison Powder
            then
                poisoned=true
                echo "$pick has been poisoned! Each time you move to a new room, you will lose 10 health!"
                sleep 1
        fi
    echo Your health: $health
    echo Enemy health: $ehealth
    sleep 1
    if [[ $ehealth -le 0 ]]
        then echo You defeated Team Rocket!
        sleep 1
    fi
    done
    if [[ "$1" = "boss.jpc" && $ehealth -le 0 ]]
        then win
    fi
}

move () {
    if [[ $(cd $1) -eq 0 && -d $1 ]]
        then cd $1
            echo "You are now $1"
    elif [[ $1 = "ground" || ! -d * ]]
        then cd ..
            echo "You have left the room"
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
    if [[ -f "rocket1.jpc" ]]
        then battle rocket1.jpc
    elif [[ -e "rocket2.jpc" ]]
        then battle rocket2.jpc
    elif [[ -e "rocket3.jpc" ]]
        then battle rocket3.jpc
    elif [[ -e "boss.jpc" ]]
        then battle boss.jpc
    fi
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
    if [[ -e "default.jpc" ]]
        then cat "default.jpc"
        sleep 1
    fi
    if [[ -e "stimpack.jpc" ]]
        then ((health+=50))
    fi
    if [[ -e "antidote.jpc" ]]
        then echo "Obtained an antidote!"
            item[0]=1
        sleep 1
    fi
    if [[ ${item[0]} -eq 1 && "$poisoned" = "true" ]]
        then poisoned=false
        echo "You cure your $pick of poison by feeding him the antidote!"
    fi
    if [ $started -eq 1 ]
        then prompt
    fi
done



if [[ $health -eq 0 ]]
    then echo "You're dead! Better luck next time!"
fi 
echo "Bye!"
