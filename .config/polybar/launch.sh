#!/usr/bin/env bash

REFRESH=$1

# Gets the CPU thermal sensor we want
# The hwmon-path sometimes change
CPU_LABEL="coretemp"
CPU_CORE="Package id 0"
for i in /sys/class/hwmon/hwmon*/temp*_input; do
  label=$(<$(dirname $i)/name)
  echo "$label"
  if [[ "$label" == *"$CPU_LABEL"* ]]; then
    core=$(cat ${i%_*}_label 2>/dev/null || $(basename ${i%_*}))
    if [[ "$core" == *"$CPU_CORE"* ]]; then
      sensorsPath=$(readlink -f $i)
      break
    fi
  fi
done

export POLY_SENSORS=xfce0-sensors
export POLY_CALENDAR=orage
export POLY_HWMON_PATH="${sensorsPath}"

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
#killall -q polybar

# Wait until the processes have been shut down
# while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch bar
echo "---" | tee -a /tmp/polybar1.log

args=""
if [[ "$REFRESH" == "--refresh"  ]]; then
  args="-r"
fi

polybar ${args} saibotbar 2>&1 | tee -a /tmp/polybar1.log & disown

echo "Bars launched..."
