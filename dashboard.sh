#!/bin/bash
# WOID - Worst Operatable Irregular Dash
#hyprctl dispatch focuswindow "class:dash-box"
hyprctl --batch "keyword cursor:no_warps true; dispatch focuswindow class:dash-box; keyword cursor:no_warps false"


OLD_DASH=$(hyprctl clients -j | jq -r '.[] | select(.class == "dash-box") | .address' | tail -n +2)
for addr in $OLD_DASH; do
    hyprctl dispatch closewindow address:$addr
done


cleanup() {
    # RESTORE SYSTEM STATE
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


#  hyprctl dispatch focuswindow class:dash-box >/dev/null 2>&1

get_sys()  {
echo "$USER@$HOSTNAME"
}

#get_stats() {
#    local time=$(date +'%H:%M')
#    local lang=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | cut -c1-2 | head -n 1)
#    local vol_data=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
#    if [[ "$vol_data" == *"[MUTED]"* ]]; then local vol="MUTE"; else local vol=$(echo "$vol_data" | awk '{print int($2*100)"%"}'); fi
#    local bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "0")
#    printf " Clk: %s  |  Vol: %s  |  Lan: %s  |  Bat: %s%% " "$time" "$vol" "${lang:-EN^^}" "$bat"
#}

tput civis 
clear

while true; do



    # Main Loop Focus Guard (Silent)
#    hyprctl dispatch focuswindow class:dash-box >/dev/null 2>&1
    echo -ne "\033[H"
    echo -e  "\n\n\n\n   			  $(get_sys) \n\n\n\n\n"
#    echo -e "\n   $(get_stats)"
    echo -e "  +------------------------------------------------------------+"
    echo -e "   1. LAUNCH APPS"
#    echo -e "   2. KILL PROCESSES"
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

#2) tput cnorm
#   USER_PROCS=$(ps -u $USER -o comm= | sort -u | grep -vE "<-server|Utility|Web|WebExtensions|hyprland|Hyprland|Xwayland|steamwebhelper|steam-runtime-l|xdg-|dbus-|systemd|waybar|sway|pipewire|wireplumber|sh$|bash$|fzf|bwrap|cat|swww|pdm|dconf|at-spi|gvfsd|flatpak|crashhelper|forkserver|isolated|zypak|sort|Socket|sd-pam|RDD|ps$|Privileged|p11-kit|kitten|inotifywait|polkit|dunst|grep")
#   SELECTED=$(echo "$USER_PROCS" | fzf --reverse --prompt="KILL > ")

#   if [ -n "$SELECTED" ]; then
#           pkill -9 "$SELECTED"
       
#       cleanup
#   fi
#   tput civis ;;

        2) (nohup hyprctl dispatch exec "[workspace f+0] kitty sudo pacman -Syu" >/dev/null 2>&1 &); sleep 0.1; cleanup ;;
        3) (nohup hyprctl dispatch exec "[workspace f+0] sleep 0.3 && /home/$USER/.config/dash/screenshot.sh" >/dev/null 2>&1 &); sleep 0.1; cleanup ;;        
        4) echo -e "\n  [ 1.SHUTDOWN  2.REBOOT  3.LOGOUT  4.LOCK  0.BACK ]"
           read -rsn1 p_input
           case "$p_input" in 1) systemctl poweroff ;; 2) systemctl reboot ;; 3) loginctl terminate-user "$USER" ;; 4) (nohup hyprlock >/dev/null 2>&1 &) & exit  ;; *) clear ;;  esac ;;
#        5) tput cnorm  
#           RAW_CMD2=$($HOME/.config/themes/color.sh)
#   if [ -n "$RAW_CMD2" ]; then
#       clear 
#       hyprctl dispatch exec -- "$RAW_CMD2" >/dev/null 2>&1
#       cleanup
#       exit 0 
#   fi
#   tput civis ;;
#

#	5) tput cnorm; $HOME/.config/themes/color.sh;  clear ;;
        5) tput cnorm
	   bash "$HOME/.config/themes/tools/picker.sh"
           STATUS=$?

           if [ $STATUS -eq 0 ]; then
               cleanup
           else
               clear
               tput civis
           fi ;;

#        6) tput cnorm; rm ~/.config/kitty/dark-theme.auto.conf; rm ~/.config/kitty/light-theme.auto.conf; rm ~/.config/kitty/no-preference-theme.auto.conf; sleep 3; cleanup ;;
#        7) tput cnorm; hyprctl activewindow -j | jq  '.title, .class';;
        0|q) cleanup ;;
    esac
done
