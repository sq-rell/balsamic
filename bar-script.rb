

def make_button(text, command, button)
	return "\%{#{button}:" + command + ":}" + text + "\%{A}"
end

def basic_colors()
	return '%{B-}%{F-}'
end

def get_battery()
	output = `acpi -b`.chomp.split(', ')
	
	battery_level = output[1]
	
	if output[0].match(/Cha/)
		fg_color = '000000'
		bg_color = '00ff00'
	else
		bg_color = "000000"
		case battery_level.chop.to_i
		when 81..100
			fg_color = "00ff00"
		when 21..80
			fg_color = "ffffff"
		when 11..20
			fg_color = "ff0000"
		else
			fg_color = "000000"
			bg_color = "ff0000"
		end
	end
	
	return "\%{F\##{fg_color}}\%{B\##{bg_color}}Battery: " + battery_level + '%{B-}'
end


def get_volume()
	
	output = `vol get`.split
	if output[1] == "off"
		mute_string = "XX"
	else
		mute_string = "OO"
	end
	
	down_button = '%{B#700000}' + make_button('VV', 'vol down', 'A') + '%{B-}'
	
	up_button = '%{B#700000}' + make_button('AA', 'vol up', 'A') + '%{B-}'
	
	mute_button = '%{B#700000}' + make_button(mute_string, 'vol flip', 'A') + '%{B-}'
	
	
	return "\%{B-}\%{F#bbbbff}Volume: " + down_button + " #{output[0]} " + up_button + " " + mute_button
end

def get_brightness()
	
	output = `bright get`.chomp
	
	down_button = '%{B#000090}' + make_button('VV', 'bright down', 'A') + '%{B-}'
	
	scroll_button = make_button(make_button(output, 'bright up', 'A5'), 'bright down', 'A4')
	
	up_button = '%{B#000090}' + make_button('AA', 'bright up', 'A') + '%{B-}'
	
	return "\%{B-}\%{F\#ffff00}Brightness: " + down_button + ' ' + scroll_button + ' ' + up_button
end

def get_date()
	output = `date`
	return basic_colors() + output.chomp
end

def get_power()
	suspend_button = make_button('suspend', 'systemctl suspend', 'A')
	
	return basic_colors() + '%{R}' + suspend_button
end

def get_wifi()
	output = `nmcli device`.split("\n")[1].split
	return basic_colors() + 'Wifi: '+ output[2] + ', ' + output[3]
end

def get_self_destruct()
	return '%{R}' + make_button('self-destruct', 'pkill lemonbar', 'A') + basic_colors()
end

# puts get_battery()

while true
	puts '%{l}' + get_date() + '  ' + get_battery() + '  ' + get_brightness() + '  ' + get_volume() + '%{r}' + get_wifi() + '  ' + get_self_destruct() +'  ' + get_power() + basic_colors()
	
	sleep(1)
end

