#!/bin/bash

###############################################################################
# Locking process

SCRIPTNAME=`basename $0`
PIDFILE=./${SCRIPTNAME}.pid

if [ -f ${PIDFILE} ]; then
   # verify if the process is actually still running under this pid
   OLDPID=`cat ${PIDFILE}`
   RESULT=`ps -ef | grep ${OLDPID} | grep ${SCRIPTNAME}`  

   if [ -n "${RESULT}" ]; then
     echo "Script already running! Exiting"
     exit 255
   fi

fi

# grab pid of this process and update the pid file with it
PID=`ps -ef | grep ${SCRIPTNAME} | head -n1 |  awk ' {print $2;} '`
echo ${PID} > ${PIDFILE}


###############################################################################
# Setup vars

PNAME="Network Connection Assistant"
YAD_PID=
tmpfile="/tmp/_nca_select.txt"
list=()
operation=
state="idle"
run=true

# Temp file for selection
echo -n "" > ${tmpfile}
export tmpfile

# Pipe comunication between subshell and parent
YAD_PIPE=$(mktemp -u --tmpdir yad_nca.XXXXXX)
MAIN_PIPE=$(mktemp -u --tmpdir yad_main_nca.XXXXXX)
mkfifo "$YAD_PIPE"
mkfifo "$MAIN_PIPE"


###############################################################################
# Functions

function apply_style_connected() {
  # signal="<b>${signal}</b>" - can't apply in numbers because the sorting won't work in yad
  # ssid="<span bgcolor='#f88'>📶 <b>${ssid}</b> <i>(in use)</i></span>"
  ssid="<span>📶 <b>${ssid}</b> <i>(in use)</i></span>"
}

function wifi_strength_bar() {
  #local icon_prefix="network-wireless-signal"
  local icon_prefix="nm-signal"
  local level=
  local secure=

  if [[ $1 -lt 20 ]]; then
    level=0 #level="none";
  elif [[ $1 -lt 40 ]]; then
    level=25 #level="weak";
  elif [[ $1 -lt 55 ]]; then
    level=50 #level="ok";
  elif [[ $1 -lt 80 ]]; then
    level=75 #level="good";
  else
    level=100 #level="excellent";
  fi

  if [[ "$2" =~ WPA|WEPS ]]; then
    secure="-secure"
  fi

  printf "%s-%s%s" "${icon_prefix}" "${level}" "${secure}"
}

function refresh_wifi_list() {
  list=()
  nmcli device wifi rescan
  echo "# ✓ Rescan..."
  local wifiConnections=$(nmcli -t -f in-use,ssid,signal,security device wifi list)
  if [[ "${#wifiConnections[@]}" -eq 0 ]]; then
    sleep 0.5
    wifiConnections=$(nmcli -t -f in-use,ssid,signal,security device wifi list)
  fi
  
  local is_in_use=
  local signal_img=

  wifiConnections=${wifiConnections//&/&amp;}
  echo "# ✓ Listing..."
  while IFS=":" read -r inuse ssid signal security; do
    is_in_use="FALSE"
    if [[ "${inuse}" == "*" ]]; then
      apply_style_connected
      is_in_use="TRUE"
    fi
    signal_img=$(wifi_strength_bar "${signal}" "${security}")
    list+=( "${signal_img}"  "${ssid}" "${security}" "${is_in_use}" )
  done < <(printf %s "${wifiConnections}")
  sleep 0.1
  echo "# ✓ Done!"
  sleep 0.4
  #printf '%s\n' "${list[@]}"
}

function show_loading_connections() {
  refresh_wifi_list > >(yad --progress --pulsate --title="Please Wait" --size=fit --text="$1" --align=center --hide-text --image="state-sync" --no-buttons --borders=16 --auto-close --undecorated --skip-taskbar)
}

function show_already_in_use() {
  local ssid=$(echo "$1" | grep -Po '<b>\K[^<]*')
  yad --title="Already in use" --window-icon="error" --height=48 --size=fit --borders=8 --fixed \
  --text="You're already connected to '$ssid'.\nWould you like to disconnect?" --text-align=fill \
  --skip-task-bar --close-on-unfocus --on-top \
  --button=Yes:0 --button=No:1
  local result=$?

  if [[ $result -eq 0 ]]; then
    if out=$(nmcli con down "$ssid"); then
        echo "rescan"
    fi
  fi 
}

function show_ask_password() {
  local selected=$(cat "${tmpfile}")
  IFS="|" read -a array <<< "${selected}"
  local ssid="${array[1]}"

  if [[ "${array[3]}" == "TRUE" ]]; then
    show_already_in_use "${ssid}"
    return
  fi

  if [[ "${array[2]}" =~ WPA|WEPS ]]; then
    unset passwd
    local passwd=$(yad --entry \
       --window-icon="dialog-password-symbolic" --title="Wi-Fi Network Authentication Required" --image="gtk-dialog-authentication" \
       --borders=16 --height=64 --width=300 --margins=1 --fixed --align=center \
       --button=Connect:0 --button=Cancel:1 \
       --skip-task-bar --close-on-unfocus --hide-text --licon="keepassxc-panel" \
       --text="Passwords or encryption keys are required to access\nthe Wi-Fi network '<b>${ssid}</b>'."
     )
    local result=$?
    if [[ $result -eq 0 && ! -z "${passwd}" ]]; then
      echo "state:connecting"
      echo "main:close"
      if ! out=$(nmcli device wifi connect "$ssid" password ""$passwd"" 2>&1); then
        yad --window-icon="error" --title="Connection failed" \
          --fixed --borders=16 \
          --close-on-unfocus --skip-task-bar \
          --text="Failed to connect to '$ssid'." \
          --button=OK:0
        echo "main:show"
        echo "state:idle"
      else
        echo "rescan"
      fi
      unset passwd
    fi  

  fi
}

function show_main_window() {
   yad --title="${PNAME}" --window-icon="network-transmit" --width=600 --height=400 --align=center \
       --list --column=:IMG --column="Name" --column="Security":HD --column="In-Use":HD \
       --no-headers --search-column=2 --button-layout=edge \
       --button=Connect:"bash -c 'show_ask_password >$YAD_PIPE'" \
       --button=Rescan:"bash -c 'echo 3 >$MAIN_PIPE'" \
       --button=Cancel:"bash -c 'echo 1 >$MAIN_PIPE'" \
       --dclick-action="bash -c 'show_ask_password >$YAD_PIPE'" \
       --select-action="/bin/sh -c \"printf \%\s'|' %s >$tmpfile\"" \
   "${list[@]}" &
  YAD_PID="$!"
}

function kill_main_window() {
  if ps -p $YAD_PID > /dev/null; then
     kill -USR1 $YAD_PID
  fi
}

function rescan_connections() {
  kill_main_window
  show_loading_connections "Rescanning WiFi connections..."
  show_main_window
  #printf '%s\n' "${list[@]}"
}

function execute_operation() {
  IFS="|" read -a input <<< "$1"
  local op="${input[0]}"
  local param="${input[1]}"

  case "${op}" in
    state:* )
      local newState=(${op//:/ })
      echo "state: ${newState[1]}"
      state="${newState[1]}"
      echo "$state"
    ;;
    main:close )
      kill_main_window
    ;;
    main:show )
      show_main_window
    ;;
    rescan )
      state="rescan"
      rescan_connections
      state="idle"
    ;;
    * ) ;;
  esac
  unset op
  unset param
  unset operation
}

###############################################################################
# Setup

export -f show_ask_password
export -f show_already_in_use

function cleanup() {
  kill_main_window

  unset tmpfile
  unset show_ask_password
  unset show_already_in_use

  exec 3>&-
  exec 4>&-

  rm -f "$YAD_PIPE"
  rm -f "$MAIN_PIPE"
  rm -f "${tmpfile}"

  if [ -f ${PIDFILE} ]; then
    rm -f ${PIDFILE}
  fi

}

trap "trap - SIGTERM && cleanup && kill -- -$$" SIGINT SIGTERM EXIT


###############################################################################
# Main


show_loading_connections "Loading WiFi connections..."
show_main_window

# Open pipe and unblock reading
exec 3<> $YAD_PIPE
exec 4<> $MAIN_PIPE

while ${run}; do
  if [[ ! -e "${PIDFILE}" ]]; then
    break
  fi

  if [[ ! -z "${operation}" ]]; then
    execute_operation "${operation}"
  fi

  # Workaround to close application when main window is closed
  if [[ "$state" == "idle" ]]; then
    if ! ps -p $YAD_PID > /dev/null; then
        exit 0;
    fi
  fi

  # Reads main window exit status
  while read -t 0.1 -r mainStatus; ret=$?
    [ $ret -eq 0 ]; do
    if [[ $mainStatus -eq 1 || $mainStatus -eq 252 ]]; then
      exit 0
      break
    elif [[ $mainStatus -eq 3 ]]; then
      operation="rescan"
      break
    fi
  done <"$MAIN_PIPE"


  if [[ ! -z "${operation}" ]]; then
    continue
  fi

  while read -t 0.1 -r msg; ret=$?
    [ $ret -eq 0 ]; do
    if [ ! -z "${msg}" ]; then
       operation="${msg}"
       break
    fi
  done <"$YAD_PIPE"

done

