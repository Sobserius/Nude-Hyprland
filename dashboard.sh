#!/bin/bash

hyprctl --batch "keyword cursor:no_warps true; dispatch focuswindow class:dash-box; keyword cursor:no_warps false"


OLD_DASH=$(hyprctl clients -j | jq -r '.[] | select(.class == "dash-box") | .address' | tail -n +2)
for addr in $OLD_DASH; do
    hyprctl dispatch closewindow address:$addr
done


cleanup() {

    hyprctl keyword device:all:enabled true > /dev/null 2>&1
    hyprctl --batch "keyword cursor:no_hardware_cursors false; \
#                     keyword cursor:inactive_timeout 0; \
#                     keyword input:follow_mouse 1; \
#                     keyword seat:default:cursor_size 24; \
#                     keyword windowrulev2 unset,class:dash-box" > /dev/null 2>&1
    tput cnorm 
    hyprctl dispatch closewindow class:dash-box > /dev/null 2>&1
    exit
}

trap cleanup SIGINT SIGTSTP EXIT SIGUSR1


get_sys()  {
echo "$USER@$HOSTNAME"
}



tput civis 
clear

while true; do



    echo -ne "\033[H"
    echo -e  "\n\n\n\n   			  $(get_sys) \n\n\n\n\n"
    echo -e "  +------------------------------------------------------------+"
    echo -e "   1. LAUNCH APPS"
    echo -e "   2. CHECK UPDATES"
    echo -e "   3. SCREENSHOT"
    echo -e "   4. POWER MENU"
    echo -e "   5. CHANGE THEME"
    echo -e "   0. EXIT DASH"
    echo -e "  +------------------------------------------------------------+"

    

    read -rsn1  input


if [[ $input == $'\e' || -z $input ]]; then
    cleanup
fi

    case "$input" in
1) tput cnorm
   RAW_CMD=$(j4-dmenu-desktop --no-generic --no-exec --dmenu="fzf --reverse --prompt='RUN > '" 2>/dev/null)

   if [ -n "$RAW_CMD" ]; then
       clear
       hyprctl dispatch -- exec "$RAW_CMD"
       cleanup
       exit 0
   fi
   tput civis ;;



        2) (nohup hyprctl dispatch exec "[workspace f+0] kitty sudo pacman -Syu" >/dev/null 2>&1 &); sleep 0.1; cleanup ;;
        3) (nohup hyprctl dispatch exec "[workspace f+0] sleep 0.3 && /home/$USER/.config/dash/screenshot.sh" >/dev/null 2>&1 &); sleep 0.1; cleanup ;;        
        4) echo -e "\n  [ 1.SHUTDOWN  2.REBOOT  3.LOGOUT  4.LOCK  0.BACK ]"
           read -rsn1 p_input
           case "$p_input" in 1) systemctl poweroff ;; 2) systemctl reboot ;; 3) loginctl terminate-user "$USER" ;; 4) nohup hyprlock & cleanup   ;; *) clear ;;  esac ;;

        5) tput cnorm
                  bash "$HOME/.config/themes/tools/picker.sh"
                  STATUS=$?
                  if [ $STATUS -eq 0 ]; then
                      cleanup
                  else
                      clear
                      tput civis
                  fi ;;
               *) clear ;;
           esac ;;
        0|q) cleanup ;;
    esac
done

