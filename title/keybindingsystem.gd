extends Node

var action_bindings = {}

var original_bindings = {}

func _ready():
	InputMap.load_from_project_settings()
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if events.is_empty() or not events[0] is InputEventKey:
			continue
		original_bindings[action] = events[0].keycode
		

	load_keybindings()

func save_keybindings():
	var config = ConfigFile.new()
	
	for action in action_bindings.keys():
		config.set_value("keybindings", action, action_bindings[action])
	
	config.save("user://keybindings.cfg")

func load_keybindings():
	var config = ConfigFile.new()
	var err = config.load("user://keybindings.cfg")
	
	if err == OK:
		for action in config.get_section_keys("keybindings"):
			var key = config.get_value("keybindings", action)
			action_bindings[action] = key
			update_input_map(action, key)
	else:
		initialize_default_bindings()

func initialize_default_bindings():
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if events.is_empty() or not events[0] is InputEventKey:
			continue
		update_input_map(action, original_bindings[action])

func update_input_map(action_name, key_code):
	InputMap.action_erase_events(action_name)
	
	var event = InputEventKey.new()
	event.keycode = key_code
	
	InputMap.action_add_event(action_name, event)
	
	action_bindings[action_name] = key_code

var current_action_rebinding = null

func start_rebinding(action_name):
	current_action_rebinding = action_name

func _input(event):
	if current_action_rebinding != null and event is InputEventKey and event.pressed:
		update_input_map(current_action_rebinding, event.keycode)
		
		var button = get_node("../KeybindingScreen/ScrollContainer/VBoxContainer").find_node(current_action_rebinding + "_Button")
		if button:
			button.text = OS.get_keycode_string(event.keycode)
		
		current_action_rebinding = null
		save_keybindings()
		
		get_viewport().set_input_as_handled()
