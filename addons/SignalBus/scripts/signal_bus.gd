@tool
extends Node
## Create and manage global signals directly from the Godot editor!
## @experimental
##
## [SignalBus] is simple editor plugin that allows the creation of globally accessible [Signal]s. 
## Simply enable the plugin in [b]project-settings/plugins[/b] and a new "[SignalBus]" dock will appear in the project settings.
## Registerd global signals will be saved to ProjectSettings.

signal global_signal_added()

signal global_signal_changed()

signal global_signal_removed()

signal global_signals_loaded()

const SETTINGS_KEY := "signal_bus/signals"

static var _signal_registery: Dictionary = {}

func _ready():
	load_signals()

## Checks if a given global signal is registered in SignalBus
func has_global_signal(signal_name:String) ->bool:
	return _signal_registery.has(signal_name) and has_signal(signal_name)

## Commit registered global signals to ProjectSettings
static func save_signals():
	ProjectSettings.set_setting(SETTINGS_KEY,_signal_registery)
	ProjectSettings.save()

## Retrieves global signals from ProjectSettings and sets signal registery
func load_signals() -> void:
	# Replace in-memory registry with what’s on disk
	_signal_registery = ProjectSettings.get_setting(SETTINGS_KEY, {})

	# Remove any existing user signals on this node
	for s in get_signal_list():
		var name: String = s.name
		if has_user_signal(name):
			remove_user_signal(name)

	# Re-register from the registry
	for signal_name in _signal_registery.keys():
		var params: Array = _signal_registery[signal_name]
		# ensure signature is up to date
		if has_signal(signal_name):
			remove_user_signal(signal_name)
		add_user_signal(signal_name, params)
	
	global_signals_loaded.emit()

## Get all signal parameters for a given signal
func get_global_signal_parameters(signal_name:String) -> Array:
	if _signal_registery.has(signal_name):
		return _signal_registery.get(signal_name)
	else:
		return []

## Add a new parameter to an already existing global signal
func add_signal_parameter(signal_name:String,parameter_name:String,parameter_type:int) ->bool:
	# signal must exist
	if not has_signal(signal_name):
		print_rich("[color=red][b]Could not add parameter '%s' to '%s': signal not found.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	# must have a registry entry
	if not _signal_registery.has(signal_name):
		print_rich("[color=red][b]Could not add parameter '%s' to '%s': no registry entry.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	var params := _signal_registery.get(signal_name)  # Array of Dictionaries

	# prevent duplicate names
	for p in params:
		if p.get("name","") == parameter_name:
			print_rich("[color=red][b]Cannot add parameter: '%s' already exists on '%s'.[/b][/color]"
					   % [parameter_name, signal_name])
			return false

	# append the new parameter
	var new_param = {
		"name": parameter_name,
		"type": parameter_type
	}
	params.append(new_param)

	# re-register signal with updated params
	_signal_registery.set(signal_name,params)
	remove_user_signal(signal_name)
	add_user_signal(signal_name, params)
	save_signals()
	global_signal_changed.emit()

	return true

## Remove a parameter from an already existing global signal
func remove_signal_parameter(signal_name:String, parameter_name:String) -> bool:
	# Signal must exist on this node
	if not has_signal(signal_name):
		print_rich("[color=red][b]Could not remove parameter '%s' from '%s': signal not found.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	#  Must have a registry entry
	if not _signal_registery.has(signal_name):
		print_rich("[color=red][b]Could not remove parameter '%s' from '%s': no registry entry.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	var params := _signal_registery.get(signal_name)   # Array of Dictionaries

	# Locate and remove
	var removed := false
	for i in range(params.size()):
		if params[i].get("name", "") == parameter_name:
			params.remove_at(i)
			removed = true
			break

	if not removed:
		print_rich("[color=red][b]Parameter '%s' not found on signal '%s'.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	# Re-register the signal with updated parameter list
	_signal_registery.set(signal_name,params)
	remove_user_signal(signal_name)
	add_user_signal(signal_name, params)

	# Persist and notify
	save_signals()
	global_signal_changed.emit()
	return true

## Set the signal name for an already registered global signal
func set_signal_name(current_name:String, new_name:String) -> bool:
	if not has_global_signal(current_name):
		print_rich("[color=red][b]Global signal '%s' not found in SignalBus. Could not rename.[/b][/color]" % current_name)
		return false
	var params := _signal_registery.get(current_name)
	if not remove_global_signal(current_name):
		return false
	_signal_registery.erase(current_name)
	if not add_global_signal(new_name,params):
		return false
	save_signals()
	global_signal_changed.emit()
	return true

## Set a new parameter name for a given signal and parameter name
func set_signal_parameter_name(signal_name:String,original_name:String,new_name:String) -> bool:
	if not has_signal(signal_name):
		print_rich("[color=red][b]Could not remove '%s' from SignalBus. Signal not found.[/b][/color]" % signal_name)
		return false
	if not _signal_registery.has(signal_name):
		print_rich("[color=red][b]Could not remove '%s' from SignalBus. Signal name not found in the registery.[/b][/color]" % signal_name)
		return false
	
	var params := _signal_registery.get(signal_name)

	var found := false
	for p in params:
		if p.has("name") and p.name == original_name:
			p.name = new_name
			found = true
			remove_user_signal(signal_name)
			break

	if not found:
		print_rich("[color=red][b]Parameter '%s' not found on signal '%s'.[/b][/color]" 
				   % [original_name, signal_name])
		return false

	# update registry and re-register the signal
	_signal_registery.set(signal_name,params)
	add_user_signal(signal_name, params)
	
	save_signals()
	global_signal_changed.emit()
	return true

## Set a new parameter type for a give signal and parameter name
func set_signal_parameter_type(signal_name:String, parameter_name:String, new_type:int) -> bool:
	# check that Signal exists
	if not has_signal(signal_name):
		print_rich("[color=red][b]Could not change type of '%s' on signal '%s': signal not found.[/b][/color]"
				   % [parameter_name, signal_name])
		return false
	# Validate that signal is in registery
	if not _signal_registery.has(signal_name):
		print_rich("[color=red][b]Could not change type of '%s' on signal '%s': no registry entry.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	var params := _signal_registery.get(signal_name)

	# Find the param by name and update its int type
	var found := false
	for p in params:
		if p.get("name", "") == parameter_name:
			p["type"] = new_type
			found = true
			break

	if not found:
		print_rich("[color=red][b]Parameter '%s' not found on signal '%s'.[/b][/color]"
				   % [parameter_name, signal_name])
		return false

	# Re-register the signal so Godot picks up the new signature
	_signal_registery.set(signal_name,params)
	remove_user_signal(signal_name)
	add_user_signal(signal_name, params)

	# Persist and emit change
	save_signals()
	global_signal_changed.emit()
	return true

## Registers a new Signal into the [SignalBus].
## Returns true if succesful, false otherwise.
func add_global_signal(signal_name:String, parameters:Array = [])->bool:
	if _signal_registery.has(signal_name) or has_signal(signal_name):
		print_rich("[color=red][b]Cannot register GlobalSignal. Signal name '%s' already taken.[/b][/color]" % signal_name)
		return false
	_signal_registery.set(signal_name,parameters)
	add_user_signal(signal_name,parameters)
	save_signals()
	global_signal_added.emit()
	return true

## Removes a Signal from the [SignalBus].
## Returns true if succesful, false otherwise.
func remove_global_signal(signal_name:String)->bool:
	if not has_signal(signal_name):
		print_rich("[color=red][b]Could not remove '%s' from SignalBus. Signal not found.[/b][/color]" % signal_name)
		if _signal_registery.has(signal_name):
			print_rich("[color=red][b]Orpahaned signal name '%s' found in SignalBus registery.[/b][/color]" % signal_name)
			_signal_registery.erase(signal_name)
			save_signals()
		return false
	if not _signal_registery.has(signal_name):
		print_rich("[color=red][b]Could not remove '%s' from SignalBus. Signal name not found in the registery.[/b][/color]" % signal_name)
		return false	
	_signal_registery.erase(signal_name)
	remove_user_signal(signal_name)
	save_signals()
	global_signal_removed.emit()
	return true

## Reset all plugin project settings
func reset_plugin_project_settings():
	for signal_name in _signal_registery:
		if has_signal(signal_name):
			remove_user_signal(signal_name)
		_signal_registery.erase(signal_name)
	save_signals()
