@tool
extends EditorPlugin

var packed_dock: PackedScene = preload("uid://doq1ufore4qtw")
var dock: Control

func _enter_tree():
	dock = packed_dock.instantiate()

func _enable_plugin():
	add_autoload_singleton("SignalBus","res://addons/SignalBus/signal_bus.gd")
	add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT,dock)

func _disable_plugin():
	remove_autoload_singleton("SignalBus")
	remove_control_from_docks(dock)
	
func _exit_tree():
	dock.free()
	