@tool
extends EditorPlugin

const PLUGIN_NAME:String = "SignalBus"
const SIGNAL_BUS_SCRIPT_PATH = "res://addons/SignalBus/scripts/signal_bus.gd"
const PACKED_DOCK: PackedScene = preload("uid://doq1ufore4qtw")

var dock: Control

func _enter_tree() -> void:
	if not dock:
		dock = PACKED_DOCK.instantiate()
		add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT,dock)

func _exit_tree() -> void:
	if dock:
		if dock.get_parent():
			remove_control_from_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, dock)
		dock.free()
		dock = null # clear the reference so you won’t try again

func _enable_plugin():
	if not Engine.has_singleton(PLUGIN_NAME):
		add_autoload_singleton(PLUGIN_NAME,SIGNAL_BUS_SCRIPT_PATH)

func _disable_plugin():
	if Engine.has_singleton(PLUGIN_NAME):
		remove_autoload_singleton(PLUGIN_NAME)
	
func _get_plugin_name():
	return PLUGIN_NAME

func _apply_changes():
	SignalBus.save_signals()

func _build():
	SignalBus.save_signals()
	return true