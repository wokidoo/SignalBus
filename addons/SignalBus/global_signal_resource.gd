@tool
extends Resource
class_name GlobalSignal
## Helper [Resource] class that helps track existing global signals. Used primarly to register signals to the [SignalBus]

## Save directory for all [GlobalSignal] resource files.
const SAVE_PATH: StringName = "res://addons/SignalBus/global_signals/"

## Emitted whenever a [GlobalSignal] resource file is succefully deleted from disk.
signal file_deleted(signal_name:String)

## signal name used to register [GlobalSignal] in [SignalBus].
@export var signal_name: StringName

## opitonal global signal parameters.
@export var signal_parameters: Dictionary[String,Variant.Type] = {}

## Create a new [GlobalSignal]
static func create_global_signal(name: String, parameters: Dictionary[String,Variant.Type] = {}) -> GlobalSignal:
    var new_global_signal: GlobalSignal = GlobalSignal.new()
    new_global_signal.signal_name = name
    new_global_signal.resource_path = SAVE_PATH
    new_global_signal.resource_path += "%s.tres" % name
    new_global_signal.signal_parameters = parameters
    new_global_signal.save_resource()
    return new_global_signal 

## Sets a new name for a global signal
func set_name(name:String):
    signal_name = name
    resource_path = SAVE_PATH
    resource_path += "%s.tres" % signal_name
    emit_changed()
    save_resource()
    notify_property_list_changed()

## Modify or add any new parameters to the signal
func set_parameter(key: String, type: Variant.Type):
    signal_parameters.set(key,type)
    emit_changed()
    save_resource()
    notify_property_list_changed()

## Remove a parameter from the signal
func remove_parameter(key:String):
    if signal_parameters.erase(key):
        emit_changed()
        save_resource()
        notify_property_list_changed()

## Save [GlobalSignal] directly to disk at resource_path
func save_resource():
    var error = ResourceSaver.save(self, resource_path)
    if error != OK:
        print_debug("GlobalSignal save error: %s" % error_string(error))

## Delete [GlobalSignal] resource file at resource_path
func delete_resource_file()->bool:
    var dir = DirAccess.open(SAVE_PATH)
    if not dir:
        push_error("Cannot open dir: %s" % resource_path)
        return false
    var error = dir.remove(resource_path)
    if error != OK:
        push_error("Failed to delete '%s' (error %d)" % [resource_path,error])
        return false
    
    if Engine.is_editor_hint():
       var fs = EditorInterface.get_resource_filesystem()
       fs.scan()

    file_deleted.emit(signal_name)
    return true