extends GutTest

var original_global_signals:Dictionary
var global_signals:Dictionary

func before_all():
	global_signals = ProjectSettings.get_setting(SignalBus.SETTINGS_KEY, null)
	original_global_signals = global_signals.duplicate()
	# Ensure a clean persistent state
	global_signals.clear()

func after_all():
	# Ensure a clean persistent state
	global_signals = original_global_signals

func before_each():
	global_signals.set("test_signal",[])
	SignalBus.reset_global_signals()

func after_each():
	global_signals.clear()
	SignalBus.reset_global_signals()

# ----- Helpers -----
func helper_function(...args):
	print(args)

# ----- Tests -----
func test_adding_global_signal():
	assert_true(SignalBus.has_global_signal("test_signal"))
	assert_has_signal(SignalBus,'test_signal')

func test_removing_global_signal():
	assert_has_signal(SignalBus,'test_signal')
	global_signals.erase('test_signal')
	SignalBus.reset_global_signals()
	assert_false(SignalBus.has_signal('test_signal'))

func test_connecting_to_global_signals():
	assert_not_connected(SignalBus,self,'test_signal')
	SignalBus.connect('test_signal',self.helper_function)
	assert_connected(SignalBus,self,'test_signal')
	SignalBus.disconnect('test_signal',self.helper_function)
	assert_not_connected(SignalBus,self,'test_signal')

func test_emitting_global_signals():
	watch_signals(SignalBus)
	assert_signal_not_emitted(SignalBus,'test_signal')
	SignalBus.emit_signal('test_signal')
	assert_signal_emitted(SignalBus,'test_signal')

func test_emitting_global_signals_with_parameters():
	global_signals.set('test_signal_params',[
		{'name':'param_a','type':TYPE_OBJECT}
		])
	SignalBus.reset_global_signals()
	watch_signals(SignalBus)
	var test_object = RefCounted.new()
	SignalBus.emit_signal('test_signal_params',test_object)
	assert_signal_emitted_with_parameters(SignalBus,'test_signal_params',[test_object])
