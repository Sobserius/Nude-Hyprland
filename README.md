# Dependencies:
```hyprland kitty dunst waybar fzf jq inotify-tools imagemagick swww grim slurp hyprpicker hyprlock wl-clipboard playerctl brightnessctl j4-dmenu-desktop adw-gtk3 chafa pastel```

Arch Linux example:
```console
sudo pacman -S hyprland kitty dunst waybar fzf jq inotify-tools \
imagemagick swww grim slurp hyprpicker hyprlock \
wl-clipboard playerctl brightnessctl j4-dmenu-desktop \
adw-gtk-theme chafa pastel
```
Fedora|Rhel|CentOS example:
```console
sudo dnf install -y hyprland kitty dunst waybar fzf jq inotify-tools \
    ImageMagick swww grim slurp hyprpicker hyprlock \
    wl-clipboard playerctl brightnessctl j4-dmenu-desktop \
    adw-gtk3-theme chafa pastel
```
# Installation:
> [!CAUTION]
> The following script overwrites existing hyprland.conf, dunstrc and waybar files. Backup before proceeding.

```console
mkdir -p ~/.config/themes/tools ~/.config/dash ~/.config/hypr ~/.config/dunst ~/.config/waybar && cp colors.conf ~/.config/themes/ && cp dashboard.sh ~/.config/dash/ && cp hypridle.conf ~/.config/hypr/ && cp hyprland.conf ~/.config/hypr/ && cp hyprlock-colors.conf ~/.config/hypr/hyprlock-colors.conf && cp hyprlock.conf ~/.config/hypr/hyprlock.conf && cp launcher.sh ~/.config/dash/ && cp picker.sh ~/.config/themes/tools/ && cp style.css ~/.config/waybar/  && cp screenshot.sh ~/.config/dash/ && cp config ~/.config/waybar/ && cp sync.sh ~/.config/themes/tools/ && chmod +x ~/.config/themes/tools/*.sh ~/.config/dash/*.sh 
```
> [!NOTE]
>  Reboot required after execution.

Main scripts/configs deployed to:
```~/.config/themes/*```
```~/.config/hypr/*```

Wallpapers are stored at ```~/Wallpapers```.
> Currently, there is no universal method for applying Qt color schemes; therefore, this version of the dotfiles does not automate Qt theming.

# Desktop preview:
<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/751b8c83-c482-440e-8784-4248cc011111" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/29f47fe9-e660-47a8-b064-db092acc261b" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/f7acba08-83fa-4d1f-aad2-825c6e15943a" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/0d3da98d-d9f4-4592-a32d-56251aee5beb" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/753d45e2-b6e1-46ec-b075-447188684fa2" />

<img width="1920" height="1200" alt="image" src="https://github.com/user-attachments/assets/80b62351-949e-4c9c-8e56-a799cb0f9bb8" />
