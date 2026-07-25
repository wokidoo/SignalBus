@tool
@icon("res://addons/SignalBus/icons/signal_bus.svg")
extends Node
## Create and manage global signals directly from the Godot editor!
## @experimental
##
## [SignalBus] is simple editor plugin that allows the creation of globally accessible [Signal]s. 
## Simply enable the plugin in [b]project-settings/plugins[/b] and a new "[SignalBus]" dock will appear in the project settings.
## Registerd global signals will be saved to ProjectSettings.

const SETTINGS_KEY := "signal_bus/global_signals"

func _init() -> void:
	reset_global_signals()

## Checks if a given global signal is registered in SignalBus
func has_global_signal(signal_name:String) ->bool:
	return self.has_user_signal(signal_name)

## Get the list of parameters for a given global signal.
func get_global_signal_parameter_list(signal_name:String)->Array[Dictionary]:
	var global_signals:Dictionary= ProjectSettings.get_setting(SETTINGS_KEY, {})
	return global_signals.get(signal_name,[])

## Retrieves global signals from ProjectSettings and sets global_signals
func reset_global_signals() -> void:
	# Remove all prior global signals
	for sig in get_signal_list():
		if has_user_signal(sig.name):
			remove_user_signal(sig.name)
	var global_signals:Dictionary= ProjectSettings.get_setting(SETTINGS_KEY, {})

	# Add all global signals from project settings
	for sig in global_signals:
		if not has_user_signal(sig):
			add_user_signal(sig,global_signals.get(sig))
