@tool
extends Node
## Create and manage global signals directly from the Godot editor!
## @experimental
##
## [SignalBus] is simple editor plugin that allows the creation of globally accessible [Signal]s. 
## Simply enable the plugin in [b]project-settings/plugins[/b] and a new "[SignalBus]" dock will appear in the project settings.
## [br][br]
## To define a new [GlobalSignal], simply navigate to the [SignalBus] menu in [b]project-settings[/b]. From there you need only input a unique signal name
## and press the [b]+Add[/b] button. If done correctly, the new signal should be registered in the [SignalBus] autoload and may be emitted/connected to
## from any script!
## Emitted whenever a new user signal is added to the [SignalBus].
## Can be used to connect new user-made signals at runtime
## [br][br]
## [b]Usage:[/b]
## [codeblock lang=gdscript]
## func _ready():
##	   # Connect your global signal directly from SignalBus
##     SignalBus.connect("my-global-signal", foo)
##
## func foo():
##     # Called whenever any object emits 'my-global-signal' from SignalBus
##     print_debug("my-global-signal was emitted!")
##
## # some other script
## func _input(event:InputEvent) -> void:
##     if event.is_action_pressed("ui_accept"):
##	      SignalBus.emit_signal("my-global-signal")
## [/codeblock]
## [br]
## [color=orange][b]Note:[/b][/color] 
## [SignalBus] is not intended to replace all [Signal]s!
## I only recommended using a global signal in instances when several non-related classes need access to a shared [Signal] or when
## dealing with very complex node hierarchies where connecting and disconnecting a [Signal] might otherwise require an inelegant solution.

## Emitted whenever a new [GlobalSignal] is registered to the [SignalBus]
signal global_signal_added(name:String)

## Emitted whenever a registered [GlobalSignal] is modifided and updated in the [SignalBus]
signal global_signal_updated(name:String)

## Emitted whenever a registered [GlobalSignal] is removed from the [SignalBus]
signal global_signal_removed(name:String)

var _global_signals: Dictionary[String,GlobalSignal] = {}

func _ready():
	var files = ResourceLoader.list_directory(GlobalSignal.SAVE_PATH)
	for file_name in files:
		var path:String = GlobalSignal.SAVE_PATH + file_name
		var signal_res: GlobalSignal = ResourceLoader.load(path)
		add_global_signal(signal_res)

## Registers a new [GlobalSignal] into the [SignalBus].
## Returns true if succesful, false otherwise.
func add_global_signal(global_signal:GlobalSignal)->bool:
	var name = global_signal.signal_name
	if not self.has_signal(name):
		var args:Array = []
		for param_name in global_signal.signal_parameters:
			var dict: Dictionary = {"name":param_name, "type":global_signal.signal_parameters[param_name]}
			args.append(dict)
		self.add_user_signal(name,args)
		_global_signals.set(name,global_signal)
		global_signal.changed.connect(update_global_signal.bind(global_signal))
		global_signal.file_deleted.connect(_on_global_signal_file_deleted)
		global_signal_added.emit(name)
		print_rich("[color=orange][b]GlobalSignal '%s' successfully registed in SignalBus[/b][/color]" % name)
		return true
	else:
		print_rich("[color=red][b]Could not add signal! GlobalSignal '%s' already registered in SignalBus![/b][/color]" % name)
		return false

## Updates an already registered [GlobalSignal] in the [SignalBus]. Called automatically when a change is made to a registered [GlobalSignal]
## Returns true if succesful, false otherwise.
func update_global_signal(global_signal:GlobalSignal)->bool:
	var name = global_signal.signal_name
	if self.has_signal(name) and _global_signals.has(name):
		# Preserve prior connections
		var connections: Array = get_signal_connection_list(name)
		# Remove old signal
		self.remove_user_signal(name)
		# Rebuild updated signal with correct parameters
		var args:Array = []
		for param_name in global_signal.signal_parameters:
			var dict: Dictionary = {"name":param_name, "type":global_signal.signal_parameters[param_name]}
			args.append(dict)
		self.add_user_signal(name,args)
		# reconnect signal
		for conn in connections:
			connect(name, conn["callable"], conn["flags"])
		global_signal_updated.emit(name)
		return true
	print_rich("[color=red][b]GlobalSignal '%s' failed to updated in SignalBus[/b][/color]" % name)
	return false

## Removes an already registered [GlobalSignal] from the [SignalBus].
## Returns true if succesful, false otherwise.
func remove_global_signal(global_signal:GlobalSignal)->bool:
	var name = global_signal.signal_name
	if self.has_signal(name) and _global_signals.has(name):
		self.remove_user_signal(name)
		global_signal.changed.disconnect(update_global_signal)
		global_signal.file_deleted.disconnect(_on_global_signal_file_deleted)
		_global_signals.erase(name)
		global_signal_removed.emit(name)
		print_rich("[color=orange][b]GlobalSignal '%s' successfully removed from SignalBus[/b][/color]" % name)
		return true
	print_rich("[color=red][b]GlobalSignal '%s' failed to removed from SignalBus[/b][/color]" % name)
	return false

func _on_global_signal_file_deleted(signal_name:String):
	if self.has_signal(signal_name) and _global_signals.has(signal_name):
		var signal_res: GlobalSignal = _global_signals.get(signal_name)
		remove_global_signal(signal_res)

