@tool
extends EditorPlugin

const PLUGIN_NAME := "SignalBus"
const SIGNAL_BUS_SCRIPT_PATH := "res://addons/SignalBus/scripts/signal_bus.gd"
const PACKED_DOCK: PackedScene = preload("uid://doq1ufore4qtw")

var dock: Control

func _enter_tree() -> void:
    # Project might open with plugin already enabled:
    if ProjectSettings.has_setting("autoload/%s" % PLUGIN_NAME):
        call_deferred("_create_dock")

func _exit_tree() -> void:
    _destroy_dock()

func _enable_plugin() -> void:
    if not ProjectSettings.has_setting("autoload/%s" % PLUGIN_NAME):
        add_autoload_singleton(PLUGIN_NAME, SIGNAL_BUS_SCRIPT_PATH)
    call_deferred("_create_dock")

func _disable_plugin() -> void:
    _destroy_dock()
    var sb := _get_signal_bus_node()
    if sb and sb.has_method("save_signals"):
        sb.call("save_signals")
    if ProjectSettings.has_setting("autoload/%s" % PLUGIN_NAME):
        remove_autoload_singleton(PLUGIN_NAME)

func _create_dock() -> void:
    if dock: 
        return
    # Wait until /root/SignalBus exists
    while not get_tree().root.has_node("/root/%s" % PLUGIN_NAME):
        await get_tree().process_frame

    # Wait until it finishes loading from ProjectSettings (first-time enable after restart)
    var sb := _get_signal_bus_node()
    if sb and sb.has_signal("signals_loaded"):
        # If it already loaded it may have emitted before we connected; just proceed.
        # To be safe, wait 1 frame and check for user signals:
        var had_user := false
        for s in sb.get_signal_list():
            if sb.has_user_signal(s.name):
                had_user = true
                break
        if not had_user:
            # connect once and wait
            var c := Callable(self, "_on__signals_loaded_dummy")
            sb.signals_loaded.connect(c, CONNECT_ONE_SHOT)
            await sb.signals_loaded

    dock = PACKED_DOCK.instantiate()
    add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, dock)

func _destroy_dock() -> void:
    if dock:
        if dock.get_parent():
            remove_control_from_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, dock)
        dock.queue_free()
        dock = null

func _get_plugin_name() -> String:
    return PLUGIN_NAME

func _apply_changes() -> void:
    _signal_bus_call_or_fallback("save_signals")

func _build() -> bool:
    _signal_bus_call_or_fallback("save_signals")
    return true

func _get_signal_bus_node() -> Node:
    return get_tree().root.get_node_or_null("/root/%s" % PLUGIN_NAME)

func _signal_bus_call_or_fallback(method: String, args: Array = []) -> void:
    var sb := _get_signal_bus_node()
    if sb and sb.has_method(method):
        sb.callv(method, args)
    elif sb.has_method(method):
        sb.callv(method, args)
