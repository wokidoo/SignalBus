@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_autoload_singleton("SignalBus","res://addons/signal_bus/signal_bus.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton("signalBus")
