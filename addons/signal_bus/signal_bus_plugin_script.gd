@tool
extends EditorPlugin

func _enable_plugin():
	# Initialization of the plugin goes here.
	add_autoload_singleton("SignalBus","res://addons/signal_bus/signal_bus.gd")


func _disable_plugin():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton("SignalBus")
	
