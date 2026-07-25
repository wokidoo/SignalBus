@tool
class_name SignalBusGlobalSignalParameterUI extends HBoxContainer

var param_name_line_edit: LineEdit
var param_type_option_button: OptionButton
var remove_param_button:Button

var signal_name:String
var signal_parameter:Dictionary

func _init(_signal_name:String,param_name:String,param_type:Variant.Type) -> void:
	signal_name = _signal_name
	var global_signals :Dictionary = ProjectSettings.get_setting(SignalBus.SETTINGS_KEY)
	var params:Array = global_signals.get(signal_name)
	param_name_line_edit = LineEdit.new()
	param_name_line_edit.placeholder_text = "Parameter name..."
	param_name_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	param_name_line_edit.text_submitted.connect(_on_param_name_text_submitted)
	
	param_type_option_button = OptionButton.new()
	param_type_option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	param_type_option_button.allow_reselect = true
	param_type_option_button.item_selected.connect(_on_param_type_item_selected)
	for type in range(0,TYPE_MAX):
		param_type_option_button.add_item(type_string(type),type)
	for param in params:
		if param.name == param_name:
			signal_parameter = param
			break
	if signal_parameter.is_empty():
		signal_parameter = {'name':param_name,'type':param_type}
		params.append(signal_parameter)
		ProjectSettings.save()
	
	remove_param_button = Button.new()
	remove_param_button.text = "Erase"
	remove_param_button.pressed.connect(_on_remove_param_button_pressed)
	
	param_name_line_edit.text = signal_parameter.name
	param_type_option_button.select(signal_parameter.type)

func _ready() -> void:
	add_child(param_name_line_edit)
	var type_label:Label = Label.new()
	type_label.text = "Type:"
	add_child(type_label)
	add_child(param_type_option_button)
	add_child(remove_param_button)

func reset_UI():
	param_name_line_edit.text = signal_parameter.name
	param_type_option_button.select(signal_parameter.type)

func _on_param_name_text_submitted(new_text):
	var global_signals :Dictionary = ProjectSettings.get_setting(SignalBus.SETTINGS_KEY)
	signal_parameter.name = new_text
	ProjectSettings.save()
	SignalBus.reset_global_signals()

func _on_param_type_item_selected(index):
	var global_signals :Dictionary = ProjectSettings.get_setting(SignalBus.SETTINGS_KEY)
	signal_parameter.type = index
	ProjectSettings.save()
	SignalBus.reset_global_signals()

func _on_remove_param_button_pressed():
	var global_signals :Dictionary = ProjectSettings.get_setting(SignalBus.SETTINGS_KEY)
	global_signals.get(signal_name).erase(signal_parameter)
	ProjectSettings.save()
	SignalBus.reset_global_signals()
	queue_free()
