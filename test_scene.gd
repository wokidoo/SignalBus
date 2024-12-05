extends Node

func _ready():
	SignalBus.connect("on_bus_signal_added",connect_new_signal)

func connect_new_signal(name:String):
	# Looking for '_on_player_attack' signal
	if name == "on_player_attack":
		SignalBus.connect("on_player_attack",player_attacking)

# Called whenever 'on_player_attack' signal is emitted
func player_attacking():
	print("new signal connected!")
