#!/bin/bash

# Welcome script, prints time-based greeting and system info
# Licensed under MIT, (C) Alicia Sykes 2021: https://aliciasykes.com

# Determine greeting based on the time of day
h=`date +%H`
if [ $h -lt 04 ] || [[ $h -gt 22 ]]; then greeting="Good Night"
elif [ $h -lt 12 ]; then greeting="Good morning"
elif [ $h -lt 18 ]; then greeting="Good afternoon"
elif [ $h -lt 22 ]; then greeting="Good evening"
else greeting="Hello"
fi

COLOR_P="\033[1;36m"
COLOR_S="\033[0;36m"

# Format user's name
name=$(echo "$USER" | sed 's/.*/\u&/')

# Make welcome message
WELCOME_MSG="$greeting $name!"

# Print welcome message, using figlet & lolcat if availible
if hash lolcat 2>/dev/null && hash figlet 2>/dev/null; then
  echo "${WELCOME_MSG}" | figlet | lolcat
else
  echo -e "$COLOR_P${WELCOME_MSG}\033[0m\n"
fi

# Print system information with neofetch, if it's installed
if hash neofetch 2>/dev/null; then
  neofetch --shell_version off \
    --disable shell resolution de wm wm_theme theme icons terminal \
    --backend off \
    --colors 4 8 4 4 8 6 \
    --color_blocks off \
    --memory_display info
fi

timeout=0.5

echo -e "\033[1;34mToday\n------"

# Print date time
echo -e "$COLOR_S$(date '+🗓️  Date: %A, %B %d, %Y at %H:%M') \033[0m"

# Print local weather
echo -en $COLOR_S
curl -s -m $timeout "wttr.in?format=%cWeather:+%C+%t,+%p+%w"
echo -e "\033[0m"

# Print IP address
ip_address=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
ip_interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
echo -en "$COLOR_S🌐 IP: "
curl -s -m $timeout "https://ipinfo.io/ip"
echo -en " (${ip_address} on ${ip_interface})\033[0m\n"

# EOF
