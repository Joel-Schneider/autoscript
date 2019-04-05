#/bin/bash
# 30th August 2017 (C) Joel Schneider
# REQUIRES:
# xprop
# xdotools

# References:
# https://blog.sleeplessbeastie.eu/2013/01/21/how-to-automate-mouse-and-keyboard/

xprop_command=`which xprop`
xdotool_command=`which xdotool`
xte_command=`which xte`
current_stuff=""
xprop_output=""
logfile="actions.log.csv"

function get_active_window_class {
	echo "$xprop_output" | sed -n -e "s/^WM_CLASS(STRING).*\"\(.*\)\", \".*\"/\1/ p"
}

function get_active_window_instance_name {
	echo "$xprop_output" | sed -n -e "s/^WM_CLASS(STRING).*\"\(.*\)\", \"\(.*\)\"/\2/ p"
}

function get_active_window_PID {
	echo "$xprop_output" | sed -n -e "s/^_NET_WM_PID(CARDINAL) \= \(.*\)/\1/ p"
}

function update_current_stuff {
	xprop_output="$($xprop_command -id $($xdotool_command getactivewindow))"
}

last_window="x"
echo -e "Seconds\t\tNano\t\tPID\t\tType\t\tName\t\tClass"

exec 3<>$logfile
echo -e "Seconds,Nano,PID,Type,Name,Class" >&3

	
while true; do
	update_current_stuff
	window_name=`get_active_window_instance_name`
	window_class=`get_active_window_class`
	PID=`get_active_window_PID`
	#current_window="PID:\t$PID\tName:\t$window_name\tClass:\t$window_class"
	#	echo -e "$current_window"
	case "$window_name" in
		firefox)
			recognised_type="browser"
			;;
		SciTE)
			recognised_type="editor"
			;;
		Xfce4-terminal)
			recognised_type="terminal"
			;;
		Thunderbird)
			recognised_type="email"
			;;
		*)
			recognised_type="unknown"
	esac
	current_window="$PID, $recognised_type, $window_name, $window_class"
	if [ "$current_window" != "$last_window" ]; then
		#echo -en "*"
		echo -en "$(date +%s,%N)"
		echo -e ",$PID,$recognised_type,$window_name,$window_class" 
		echo "$(date +%s,%N),$PID,$recognised_type,$window_name,$window_class" >&3
		#echo -e "\t\t$PID\t\t$recognised_type\t$window_name\t\t$window_class"
	fi
	last_window="$current_window"
	#sleep 2
done
exec 3>&-