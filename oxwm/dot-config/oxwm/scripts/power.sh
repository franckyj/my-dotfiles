#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles

# Current Theme
dir="$HOME/.config/rofi"
theme='power'

# CMDs
host=`hostname`

# Options
cancel='\Uf0156 [Cancel]'
shutdown='\Uf0425 Shutdown'
reboot='\Uf0709 Reboot'
# lock=' Lock'
suspend='\Uf04b2 Suspend'
logout='\Uf0343 Logout'
yes=':) Yes'
no=':( No'

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p "$host" \
    -theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  # $lock\n
  echo -e "$cancel\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      pamixer -m
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      pkill oxwm
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
    run_cmd --shutdown
        ;;
    $reboot)
    run_cmd --reboot
        ;;
    # $lock)
    # if [[ -x '/usr/bin/betterlockscreen' ]]; then
    #   betterlockscreen -l
    # elif [[ -x '/usr/bin/i3lock' ]]; then
    #   i3lock
    # fi
    #     ;;
    $suspend)
    run_cmd --suspend
        ;;
    $logout)
    run_cmd --logout
        ;;
esac

# ========================
# #!/usr/bin/env bash

# # Simple script to handle a DIY shutdown menu with rofi.
# #
# # Requirements:
# # - rofi
# # - systemd (can be replaced for other init systems if needed)
# #
# # Instructions:
# # - Save this file as power.sh
# # - Make it executable: chmod +x /path/to/power.sh
# # - Run it

# ROFI_THEME="$HOME/.config/rofi/power.rasi"

# chosen=$(echo -e "[Cancel]\nLogout\nShutdown\nReboot" | \
#     rofi -dmenu -i -p "Power Menu" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

# case "$chosen" in
#     "Logout") pkill oxwm ;;
#     "Shutdown") systemctl poweroff ;;
#     "Reboot") systemctl reboot ;;
#     *) exit 0 ;; # Exit on cancel or invalid input
# esac
