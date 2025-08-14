@tool
extends Node
class_name SignalBusSubscriber

## Array of errors messages for editor configuration warnings.
## Updated when _are_parameters_valid is called 
var _errors:Array = []

## Refrence to currently connected 
var _parent_callable:Callable
var _prior_subscribed_signal:String

## Emitted whenever the subscribed global signal is emitted from SignalBus.
signal subscribed_signal_emitted()

## Subscribed global signal from SignalBus. 
## Emitting global signal from SignalBus will trigger [member SignalBusSubscriber.method_call] callback.
@export var subscribed_signal:String:
	set(val):
		subscribed_signal = val
		_update_subscriber()
		update_configuration_warnings()

## Method called in parent Node when SignalBus emits [member SignalBusSubscriber.subscribed_signal] 
@export var method_call:String:
	set(val):
		method_call = val
		_update_subscriber()
		update_configuration_warnings()

## Disconnects subscribed global signal from method call if true.
## Connection persists otherwise.
@export var one_shot:bool = false

func _ready():
	call_deferred("_update_subscriber")

func _update_subscriber():
	if not is_inside_tree():
		return
	if not _are_paramaters_valid():
		_disconnect_subscribed_signal()
		return

	_disconnect_subscribed_signal()
	_prior_subscribed_signal = subscribed_signal
	_parent_callable = Callable(get_parent(),method_call)
	if one_shot:
		SignalBus.connect(_prior_subscribed_signal,_parent_callable,ConnectFlags.CONNECT_ONE_SHOT)
		SignalBus.connect(_prior_subscribed_signal,_on_subscribed_signal_emitted,ConnectFlags.CONNECT_ONE_SHOT)
	else:
		SignalBus.connect(_prior_subscribed_signal,_parent_callable)
		SignalBus.connect(_prior_subscribed_signal,_on_subscribed_signal_emitted)

func _are_paramaters_valid() -> bool:
	_errors.clear()
	var is_valid:bool = true
	if get_parent() == null:
		_errors.push_front("SignalBusListener must have a valid parent node")
		is_valid = false
	if not SignalBus.has_global_signal(subscribed_signal):
		_errors.push_front("Global signal '%s' not found in SignalBus. Subsribed signal must be a registered SignalBus global signal." % subscribed_signal)
		is_valid = false
	if not get_parent().has_method(method_call):
		_errors.push_front("Callable '%s' not found parent node. Method call must exist in parent node." % method_call)
		is_valid = false
	return is_valid

func _on_subscribed_signal_emitted():
	subscribed_signal_emitted.emit()

func _disconnect_subscribed_signal():
	if _parent_callable and _prior_subscribed_signal:
		if SignalBus.is_connected(_prior_subscribed_signal,_parent_callable):
			SignalBus.disconnect(_prior_subscribed_signal,_parent_callable)
		if SignalBus.is_connected(_prior_subscribed_signal,_on_subscribed_signal_emitted):
			SignalBus.disconnect(_prior_subscribed_signal,_on_subscribed_signal_emitted)

func _exit_tree():
	_disconnect_subscribed_signal()

func _get_configuration_warnings():
	# call to update _errors
	_are_paramaters_valid()
	return _errors
