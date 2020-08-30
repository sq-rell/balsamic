

increment = 5

if ARGV.length < 1 || ARGV.length > 1
	puts "incorrect usage"
	exit(0)
end

output = `amixer get Master`.split("\n")[5].split

vol_level = output[4].delete_prefix('[').delete_suffix('%]').to_i

if ARGV[0] == "get"
	puts vol_level.to_s + " " + (output[5].delete_prefix('[').delete_suffix(']'))
else
	if ARGV[0] == "up"
		set_str = "#{vol_level < 100 - increment ? vol_level + increment : 100 }\%"
	elsif ARGV[0] == "down"
		set_str = "#{vol_level > increment ? vol_level - increment : 0 }\%"
	elsif ARGV[0] == "off" || ARGV[0] == "on"
		set_str = ARGV[0]
	elsif ARGV[0] == "flip"
		set_str = output[5] == '[off]'?"on":"off"
	else
		puts "incorrect usage"
		exit(0)
	end
	`amixer set Master #{set_str}`
end
