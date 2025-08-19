extends GutTest

var sb
var _original_settings = null
var added_called := false
var removed_called := false
var changed_called := false
var loaded_called := false
var test_global_called := false

func before_all():
	sb = get_tree().root.get_node_or_null("/root/SignalBus")
	assert_not_null(sb, "SignalBus autoload not found at /root/SignalBus")
	# Backup any existing persisted settings so tests don't permanently modify the project
	_original_settings = ProjectSettings.get_setting(sb.SETTINGS_KEY, null)
	# Ensure a clean persistent state
	ProjectSettings.set_setting(sb.SETTINGS_KEY, {})
	ProjectSettings.save()
	sb.reset_plugin_project_settings()

func after_all():
	# Restore original settings
	if _original_settings == null:
		ProjectSettings.set_setting(sb.SETTINGS_KEY, {})
	else:
		ProjectSettings.set_setting(sb.SETTINGS_KEY, _original_settings)
	ProjectSettings.save()
	sb.load_signals()

func before_each():
	sb.reset_plugin_project_settings()
	added_called = false
	removed_called = false
	changed_called = false
	loaded_called = false
	test_global_called = false

func after_each():
	sb.reset_plugin_project_settings()

# ----- Helper signal handlers -----
func _on_global_added():
	added_called = true

func _on_global_removed():
	removed_called = true

func _on_global_changed():
	changed_called = true

func _on_globals_loaded():
	loaded_called = true

func _on_test_global_called():
	test_global_called = true

# ----- Tests -----
func test_add_has_remove_global_signal():
	assert_true(sb.add_global_signal("s1"))
	assert_true(sb.has_global_signal("s1"))
	assert_true(sb.remove_global_signal("s1"))
	assert_false(sb.has_global_signal("s1"))

func test_add_duplicate_signal_fails():
	assert_true(sb.add_global_signal("dup"))
	assert_false(sb.add_global_signal("dup"))
	assert_true(sb.remove_global_signal("dup"))
	assert_false(sb.remove_global_signal("dup"))

func test_parameters_add_remove_and_get():
	var params = [{"name":"p1","type":0}, {"name":"p2","type":1}]
	assert_true(sb.add_global_signal("sig_params", params))
	# parameters stored and returned
	assert_eq(params, sb.get_global_signal_parameters("sig_params"))
	# add parameter
	assert_true(sb.add_signal_parameter("sig_params", "p3", 2))
	assert_eq(3, sb.get_global_signal_parameters("sig_params").size())
	# adding duplicate parameter name fails
	assert_false(sb.add_signal_parameter("sig_params", "p3", 2))
	# remove existing parameter
	assert_true(sb.remove_signal_parameter("sig_params", "p2"))
	# removing non-existent parameter fails
	assert_false(sb.remove_signal_parameter("sig_params", "nope"))

func test_set_signal_name_and_param_name_and_type():
	assert_true(sb.add_global_signal("oldname", [{"name":"a","type":0}]))
	# rename signal
	assert_true(sb.set_signal_name("oldname", "newname"))
	assert_true(sb.has_global_signal("newname"))
	assert_false(sb.has_global_signal("oldname"))
	# rename parameter
	assert_true(sb.set_signal_parameter_name("newname", "a", "b"))
	assert_eq("b", sb.get_global_signal_parameters("newname")[0]["name"])
	# change parameter type
	assert_true(sb.set_signal_parameter_type("newname", "b", 3))
	assert_eq(3, sb.get_global_signal_parameters("newname")[0]["type"])

func test_remove_nonexistent_signal_cleans_registry():
	# Create an orphaned entry in ProjectSettings then load and remove
	ProjectSettings.set_setting(sb.SETTINGS_KEY, {"orphan": []})
	ProjectSettings.save()
	sb.load_signals()
	# remove_global_signal should return true even if the node signal was absent and should remove orphan
	assert_true(sb.remove_global_signal("orphan"))
	assert_false(sb._signal_registery.has("orphan"))

func test_load_signals_reads_projectsettings():
	# Persist a signal via ProjectSettings and ensure load_signals registers it
	ProjectSettings.set_setting(sb.SETTINGS_KEY, {"from_ps": []})
	ProjectSettings.save()
	sb.load_signals()
	assert_true(sb.has_global_signal("from_ps"))
	sb.remove_global_signal("from_ps")

func test_signal_emission_notifications():
	sb.connect("global_signal_added", self._on_global_added)
	sb.connect("global_signal_removed", self._on_global_removed)
	sb.connect("global_signal_changed", self._on_global_changed)
	sb.connect("global_signals_loaded", self._on_globals_loaded)

	assert_true(sb.add_global_signal("emit_test"))
	assert_true(added_called)

	# parameter change triggers changed
	assert_true(sb.add_signal_parameter("emit_test", "x", 0))
	assert_true(changed_called)

	assert_true(sb.remove_global_signal("emit_test"))
	assert_true(removed_called)

	# Global signal emitted
	assert_true(sb.add_global_signal("test_signal"))
	sb.connect("test_signal", self._on_test_global_called)
	sb.emit_signal("test_signal")
	assert_true(test_global_called)
	sb.remove_global_signal("test_signal")

	# loading triggers loaded
	ProjectSettings.set_setting(sb.SETTINGS_KEY, {"load_emits": []})
	ProjectSettings.save()
	sb.load_signals()
	assert_true(loaded_called)

	# cleanup
	if sb.has_global_signal("load_emits"):
		sb.remove_global_signal("load_emits")

func test_invalid_operations_return_false():
	# Adding param to non-existent signal should fail
	assert_false(sb.add_signal_parameter("no_signal", "p", 0))
	# Removing parameter from non-existent signal fails
	assert_false(sb.remove_signal_parameter("no_signal", "p"))
	# Renaming signal that doesn't exist fails
	assert_false(sb.set_signal_name("no", "new"))
	# Changing parameter name/type on non-existent signal fails
	assert_false(sb.set_signal_parameter_name("no", "a", "b"))
	assert_false(sb.set_signal_parameter_type("no", "a", 1))
