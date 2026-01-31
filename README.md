# Dependencies:
```hyprland kitty dunst waybar fzf jq inotify-tools imagemagick swww grim slurp hyprpicker hyprlock wl-clipboard playerctl brightnessctl j4-dmenu-desktop adw-gtk3```

Arch Linux example:
```console
sudo pacman -S hyprland kitty dunst waybar fzf jq inotify-tools imagemagick swww grim slurp hyprpicker hyprlock wl-clipboard playerctl brightnessctl j4-dmenu-desktop adw-gtk-theme
```

# Installation:
> [!CAUTION]
> The following script overwrites existing hyprland.conf, dunstrc and waybar files. Backup before proceeding.

```console
mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar && cp color.sh ~/.config/themes/tools/ && cp colors.conf ~/.config/themes/ && cp dashboard.sh ~/.config/dash/ && cp hypridle.conf ~/.config/hypr/ && cp hyprland.conf ~/.config/hypr/ && cp hyprlock-colors.conf ~/.config/hypr/hyprlock-colors.conf && cp hyprlock.conf ~/.config/hypr/hyprlock.conf && cp launcher.sh ~/.config/dash/ && cp picker.sh ~/.config/themes/tools/ && cp style.css ~/.config/waybar/ && cp preview.sh ~/.config/themes/tools/ && cp screenshot.sh ~/.config/dash/ && cp config ~/.config/waybar/ && cp sync.sh ~/.config/themes/tools/ && chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh
```
> [!NOTE]
>  Reboot required after execution.

Scripts/Configs deployed to:
```~/.config/themes/*```
```~/.config/hypr/*```
```~/.config/dash/*```


Themes are stored at ~/.config/themes/palettes. 
Recommended kitty themes archive: https://github.com/dexpota/kitty-themes 
> [!NOTE]
> Currently, there is no universal method for applying Qt color schemes; therefore, this version of the dotfiles does not automate Qt theming.

# Desktop preview:
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/31198413-1c1f-46f0-9dd2-7bc1a6e1cc7e" />

<img width="1916" height="1200" alt="image" src="https://github.com/user-attachments/assets/e23aadae-9312-465c-9d70-b52dac30f153" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/4fa6fc85-31b2-475f-82cf-d50add4283b2" />


https://github.com/user-attachments/assets/26040689-ac2f-4ef9-84dc-c8ccba70d909

