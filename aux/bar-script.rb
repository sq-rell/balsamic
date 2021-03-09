
require 'rb-inotify'

class Widget
  def initialize(updater)
    @updater = updater
    @@wBasket.add(self)
    @printable = method(@updater).call
  end

  def self.setBasket(aBasket)
    @@wBasket = aBasket
  end

  def updateMe
    @printable = method(@updater).call
  end
  
  def pokeBasket
    self.updateMe
    @@wBasket.poke
  end

  def getPrintable
    @printable
  end
    
end

class WidgeBasket
  def initialize
    @myWidges = []
  end

  def add(aWidge)
    @myWidges << aWidge
  end

  def poke
    @myWidges.each do |tWidge|
      print tWidge.getPrintable + "  "
    end
    print "\n"
  end

  def updateAll
    @myWidges.each do |tW|
      tW.updateMe
    end
  end
  
end

def make_button(text, commands)
	
	prefixes = ''
	
	commands.each do |button, action|
		prefixes = prefixes + "\%{#{button}:#{action}:}"
	end
	
	
	return "#{prefixes} #{text} #{'%{A}' * commands.size}"
end

def basic_colors()
	return '%{B-}%{F-}'
end

def get_battery()
	output = `acpi -b`.chomp.split(', ')
	
	battery_level = output[1]
	
	if output[0].match(/Charg/)
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
	
	return "\%{F\##{fg_color}}\%{B\##{bg_color}}Battery: #{battery_level}#{basic_colors}"
end


def get_volume()

  mute_string = ""
	
	output = `vol get`.split
	if output[1] == "off"
	  mute_string = "\u00D8"
          mute_button = "\%{B\#700000}#{make_button(mute_string, {'A' => 'amixer set Master on > /home/denalir/.scripts/aux/bar_vol.txt'})}\%{B-}"
	else
	  mute_string = "\u266b"
          mute_button = "\%{B\#700000}#{make_button(mute_string, {'A' => 'amixer set Master off> /home/denalir/.scripts/aux/bar_vol.txt'})}\%{B-}"
	end
	
	down_button = "\%{B\#700000}#{make_button("\u25bc", {'A' => 'amixer set Master 5%- > /home/denalir/.scripts/aux/bar_vol.txt'})}\%{B-}"
	up_button = "\%{B\#700000}#{make_button("\u25b2", {'A' => 'amixer set Master 5%+ > /home/denalir/.scripts/aux/bar_vol.txt'})}\%{B-}"
	
	
	return "\%{B-}\%{F#bbbbff}Volume: #{down_button} #{output[0]} #{up_button} #{mute_button}#{basic_colors()}"
end

def get_brightness()
	
	output = `bright get`.chomp
	
	down_button = "\%{B\#000090}#{make_button("\u25bc", {'A' => 'bright down'})}\%{B-}"
	
	scroll_button = make_button((output.to_i)/100, {'A5' => 'bright up', 'A4' => 'bright down'})
	
	up_button = "%{B#000090}#{make_button("\u25b2", {'A' => 'bright up'})}\%{B-}"
	
	return "\%{B-}\%{F\#ffff00}\u263c #{down_button}#{scroll_button}#{up_button} \u263c#{basic_colors}"
end

def get_date()
	output = `date +"%R:%S %a %d %b %Y"`.chomp
	return output
end

def get_power()
	power_button = make_button('Suspend', {'A' => 'i3exit suspend'})
	
	return '%{R}' + power_button + basic_colors()
end

def get_wifi()
	output = `nmcli device`.split("\n")[1].split
	return 'Wifi: '+ output[2] + ', ' + output[3]
end

def get_self_destruct()
#	return '%{R}' + make_button('self-destruct', {'A' => "pkill lemonbar"}) + basic_colors()
	this_pid = `cat /home/denalir/.scripts/aux/bar_pids/main_pid`.chomp
	return '%{R}' + make_button('self-destruct', {'A' => "echo again; kill #{this_pid}", 'A3' => "echo stop; kill #{this_pid}"}) + basic_colors()
end

def get_diary()
	
	output = "diary"
	button_output = make_button(output, {'A' => "todairy today &", 'A3' => "todairy yesterday &"})
	return "\%{r}\%{R}#{button_output}#{basic_colors()}"
end

barBasket = WidgeBasket.new
Widget.setBasket(barBasket)

clockWidge = Widget.new(:get_date)
batWidge = Widget.new(:get_battery)
brightWidge = Widget.new(:get_brightness)
volWidge = Widget.new(:get_volume)
diaryWidge = Widget.new(:get_diary)
wifiWidge = Widget.new(:get_wifi)
sdWidge = Widget.new(:get_self_destruct)
powerWidge = Widget.new(:get_power)

barBasket.poke

Thread.new do
  bNotifier = INotify::Notifier.new
  bNotifier.watch("/sys/class/backlight/intel_backlight/brightness", :modify) do
    brightWidge.pokeBasket
  end
  bNotifier.run
end

Thread.new do
  vNot = INotify::Notifier.new
  vNot.watch("/home/denalir/.scripts/aux/bar_vol.txt", :modify) do
    volWidge.pokeBasket
  end
  vNot.run
end

#puts "hi"

while true
  barBasket.updateAll
  barBasket.poke
  sleep(1)
end


