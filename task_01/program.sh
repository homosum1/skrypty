#!/usr/bin/env bash

board=("?" "?" "?" "?" "?" "?" "?" "?" "?")
currentPlayerSymbol="O"
moves=0

draw_board() {
    for ((i=0; i<3; i++));
    do
        row=""
        for ((j=0; j<3; j++));
        do
            index=$((i * 3 + j))
            local cell="${board[$index]}"
            [[ "$cell" == "?" ]] && cell=" "
            row+="$cell"
            if [ $j -lt 2 ] 
            then
                row+=" | "
            fi
        done
        echo " $row"
        if [[ $i -lt 2 ]]; then
            echo "---+---+---"
        fi
    done
}

reset_game() {
    board=("?" "?" "?" "?" "?" "?" "?" "?" "?")
    currentPlayerSymbol="O"
    moves=0
}

save_game() {
    mkdir -p saves

    local timestamp
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filepath="saves/game_$timestamp.txt"

    local board_string=""
    for i in "${board[@]}";
    do
        board_string+="$i"
    done

    echo "$board_string" > "$filepath"
    echo "current:$currentPlayerSymbol" >> "$filepath"
    echo "moves:$moves" >> "$filepath"

    echo "Game saved to: $filepath"
}

loadGame() {
    local saves_dir="saves"
    mkdir -p "$saves_dir"

    local files=("$saves_dir"/*.txt)
    if [[ ! -e "${files[0]}" ]]; 
    then
        echo "No saves found :("
        return
    fi

    echo "Saved games:"
    local i=1
    for f in "${files[@]}";
    do
        echo "$i) -  $(basename "$f")"
        ((i++))
    done

    read -p "Enter the number of the save to load: " selected
    
    local index=$((selected - 1))

    if (( index < 0 || index >= ${#files[@]} ));
    then
        echo "Invalid selection."
        return
    fi

    local selected_file="${files[$index]}"

    if [[ ! -f "$selected_file" ]]; then
        echo "Invalid selection."
        return
    fi

    echo "Loading: $selected_file"

    # load save
    local board_line
    local turn_line
    local moves_line
    board_line=$(sed -n '1p' "$selected_file")
    turn_line=$(sed -n '2p' "$selected_file")
    moves_line=$(sed -n '3p' "$selected_file")


    for ((i=0; i<9; i++)); do
        board[$i]="${board_line:$i:1}"
    done

    currentPlayerSymbol="${turn_line#current:}"
    moves="${moves_line#moves:}"

    TwoPlayersPlay
}



TwoPlayersPlay() {

    while [[ $moves -lt 9 ]];
    do
        echo -e "\n"
        draw_board
        echo -e "\n"
    
        
        # read -p "$currentPlayerSymbol turn. Enter position (row col) " row col

        echo -n "$currentPlayerSymbol turn. Enter row and col (e.g. 1 3), or 'S' to save: "
        read -r row col

        # User wants to save
        if [[ "$row" =~ ^[Ss]$ ]];
        then
            save_game
            continue
        fi

        # val input
        if [[ ! $row =~ ^[1-3]$ || ! $col =~ ^[1-3]$ ]];
        then
            echo "Bad input. Enter numbers in range 1-3."
            continue
        fi

        # check if free
        local index=$(((row - 1) * 3 + (col - 1)))

        if [[ "${board[$index]}" != "?" ]];
        then
            echo -e "Entered position is taken, try again\n"
            continue
        fi

        # make a move
        board[$index]=$currentPlayerSymbol
        ((moves+=1))

        # switch player
        if [[ $currentPlayerSymbol == "X" ]]; 
        then
            currentPlayerSymbol="O"
        else
            currentPlayerSymbol="X"
        fi
    done

    echo -e "\n"
    draw_board
    echo -e "\nGG!\n"
}


OnePlayerPlay() {
    local -A availablePositions

    # init avaiable positions
    for i in "${!board[@]}";
    do
        availablePositions["$i"]=1
    done

    while [[ $moves -lt 9 ]];
    do
        echo -e "\n"
        draw_board
        echo -e "\n"

        if [[ $currentPlayerSymbol == "O" ]]; then
            read -p "$currentPlayerSymbol turn. Enter position (row col): " row col

            if [[ ! $row =~ ^[1-3]$ || ! $col =~ ^[1-3]$ ]]; then
                echo "Bad input. Enter numbers in range 1-3."
                continue
            fi

            local index=$(((row - 1) * 3 + (col - 1)))

            if [[ "${board[$index]}" != "?" ]]; then
                echo -e "Entered position is taken, try again\n"
                continue
            fi
        else
            keys=("${!availablePositions[@]}")
            random_index=$((RANDOM % ${#keys[@]}))
            index=${keys[$random_index]}
            echo -e "X moves to index: $index"
        fi

        board[$index]=$currentPlayerSymbol
        unset availablePositions["$index"]
        ((moves++))

        if [[ $currentPlayerSymbol == "X" ]]; then
            currentPlayerSymbol="O"
        else
            currentPlayerSymbol="X"
        fi
    done

    echo -e "\n"
    draw_board
    echo -e "\nGG!\n"
}


mainLoop() {
    while true; 
    do
        echo "Choose a mode:"
        echo "1. Two Players"
        echo "2. One Player"
        echo "3. Exit"
        echo "4. Load game"
        read -p "Enter your choice: " choice

        case "$choice" in
            1)
                reset_game
                TwoPlayersPlay
                ;;
            2)
                reset_game
                OnePlayerPlay
                ;;
            3)
                echo "Bye bye!"
                exit 0
                ;;
            4)
                loadGame
                ;;
            *)
                echo "Invalid number. Enter number in range 1-3"
                ;;
        esac
    done
}


mainLoop