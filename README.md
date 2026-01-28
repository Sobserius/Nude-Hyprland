# Dependencies:
```hyprland kitty dunst waybar fzf jq inotify-tools imagemagick swww grim slurp hyprpicker wl-clipboard playerctl brightnessctl j4-dmenu-desktop kvantum adw-gtk3 qt5ct```

Arch Linux example:
```console
sudo pacman -S hyprland kitty dunst waybar fzf jq inotify-tools imagemagick swww grim slurp hyprpicker wl-clipboard playerctl brightnessctl j4-dmenu-desktop kvantum  qt5ct adw-gtk-theme
```

# Installation:
> [!CAUTION]
> The following script overwrites existing hyprland.conf, dunstrc and waybar files. Backup before proceeding.

```console
mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst && cp color.sh ~/.config/themes/tools/ && cp colors.conf ~/.config/themes/ && cp dashboard.sh ~/.config/dash/ && cp hypridle.conf ~/.config/hypr/ && cp hyprland.conf ~/.config/hypr/ && cp hyprlock-colors.conf ~/.config/hypr/hyprlock-colors.conf && cp hyprlock.conf ~/.config/hypr/hyprlock.conf && cp launcher.sh ~/.config/dash/ && cp picker.sh ~/.config/themes/tools/ && cp preview.sh ~/.config/themes/tools/ && cp screenshot.sh ~/.config/dash/ && cp sync.sh ~/.config/themes/tools/ && chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh
```
Note: Reboot required after execution.

Scripts/Configs deployed to:
```~/.config/themes/*```
```~/.config/hypr/*```
```~/.config/dash/*```


Themes are stored at ~/.config/themes/palettes. Personally, I recommend you to use: https://github.com/dexpota/kitty-themes 

# Desktop preview:
<img width="1920" height="1198" alt="image" src="https://github.com/user-attachments/assets/82625d7d-2540-4f0d-a3b1-1fdd64711e3c" />
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/4fa6fc85-31b2-475f-82cf-d50add4283b2" />


https://github.com/user-attachments/assets/26040689-ac2f-4ef9-84dc-c8ccba70d909

