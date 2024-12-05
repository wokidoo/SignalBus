extends Node
## A system that helps manage user made [Signal]s more easily
##
## The [SignalBus] is an autoload 
## [url=https://refactoring.guru/design-patterns/singleton](singleton)[/url] 
## class that helps manage user-made signals by decoupling them from their own
## script. [SignalBus] effectively works as a router for signals. 
## [br][br]
## Any [Script] can define a new signal (with or without parameters)
## and add it to the [SignalBus] with [method SignalBus.add_signal_to_bus].
## These bus signals can then be emitted by or connected to in any
## [Script] with [method SignalBus.emit_signal] and [method SignalBus.connect]
## respectively.
## [br][br]
## [color=orange][b]Note:[/b][/color] 
## [SignalBus] is not intended to replace all [Signal]s in Godot!
## Only use this system in situations where a signal benefits from being 
## decoupled from any specific class such as when nodes need to communicate
## in a "one-to-many" or "many-to-many" fashion!
## [br][br]
## Credits to [color=teal][i][url=https://github.com/samuelfine]Samuel Fine[/url][/i][/color]
## for inspiring 
## the creation of this system with their comment left in the
## [url=https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html]
## Using Signals[/url] page of the Godot documentation!

## Emitted whenever a new user signal is added to the [SignalBus].
## Can be used to connect new user-made signals at runtime
## [br][br]
## [b]Usage:[/b]
## [codeblock lang=gdscript]
## func _ready():
##     SignalBus.connect("on_bus_signal_added", connect_new_signal)
##
## func connect_new_signal(name: String):
##     # Looking for 'on_player_attack' signal
##     if name == "on_player_attack":
##         SignalBus.connect("on_player_attack", player_attacking)
##
## # Called whenever 'on_player_attack' signal is emitted
## func player_attacking():
##     print("player is attacking!")
## [/codeblock]
signal on_bus_signal_added(name: String)

## Emitted whenever a signal was removed from [SignalBus]
signal on_bus_signal_removed(name: String)

## Array of the names of all bus signals currently held by [SignalBus].
## Updated automatically whenever a signal is added or removed from the bus
var signal_bus_list: Array

## Add a user-defined signal to the [SignalBus].
## If the signal provided is not already a member of the bus, 
## [signal SignalBus.on_bus_signal_added] is emitted.
## [br][br]
## [color=orange][b]Note:[/b][/color] 
## To add parameters to added signals, [param args] should 
## be passed as an array of dictionaries with the keys [b]name[/b] and [b]type[/b].
## These two keys will be associated with the name and data type of the added signal's
## parameters respectively. 
## [br][br]
## [b]Usage:[/b]
## [codeblock lang=gdscript]
## func _ready():
##     SignalBus.add_signal_to_bus("on_player_hit", [
##         {"name": "damage", "type": TYPE_INT},
##         {"name": "source", "type": TYPE_OBJECT},
##     ])
## [/codeblock]
func add_signal_to_bus(signal_name: String, args: Array = []):
	# Makes sure that the signal has not already been added to the bus
	if not self.has_signal(signal_name):
		self.add_user_signal(signal_name, args)
		signal_bus_list.append(signal_name)
		on_bus_signal_added.emit(signal_name)
	else:
		print("Cannot add ", signal_name, "! Signal is already a member of SignalBus")

## Remove a user-defined signal from [SignalBus].
## If the signal is a member of [SignalBus], 
## [signal SignalBus.on_bus_signal_removed] is emitted.
## [br][br]
## [b]Usage:[/b]
## [codeblock lang=gdscript]
## func _exit_tree():
##     SignalBus.remove_signal_from_bus("on_player_hit")
## [/codeblock]
func remove_signal_from_bus(signal_name: String):
	if self.has_signal(signal_name):
		self.remove_user_signal(signal_name)
		# Remove bus signal from list
		signal_bus_list.erase(signal_bus_list.find(signal_name))
		on_bus_signal_removed.emit(signal_name)
	else:
		print("Cannot remove ", signal_name, "! Signal is not a member of SignalBus")

## Returns the parameters of a signal in the [SignalBus].
## If the signal is not found, an empty array is returned.
## Each parameter is represented as a dictionary with the keys:
## - `name`: The name of the parameter.
## - `type`: The type of the parameter.
##
## [b]Usage:[/b]
## [codeblock lang=gdscript]
## func _ready():
##     SignalBus.add_signal_to_bus("on_player_hit", [
##         {"name": "damage", "type": TYPE_INT},
##         {"name": "source", "type": TYPE_OBJECT},
##     ])
##
##     var parameters = SignalBus.get_bus_signal_parameters("on_player_hit")
##     print(parameters) # Outputs: [{"name": "damage", "type": TYPE_INT}, {"name": "source", "type": TYPE_OBJECT}]
## [/codeblock]
func get_bus_signal_parameters(name:String):
	if self.has_signal(name):
		for x in self.get_signal_list():
			if x.get("name") == name:
				return x.get("args")
	else:
		print("Cannot find ", name, "! Signal is not a member of SignalBus")
