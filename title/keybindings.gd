extends ConfirmationDialog

var action_buttons = {}
var current_action = ""

func _ready():
	for connection in get_cancel_button().pressed.get_connections():
		get_cancel_button().pressed.disconnect(connection.callable)
	
	get_cancel_button().pressed.connect(_on_reset_defaults)

	_find_and_connect_buttons()
	
	_update_button_labels()


func _find_and_connect_buttons():
	for section_name in ["MovementSection", "RhythmSection", "ActionsSection"]:
		var section = $ScrollContainer/VBoxContainer.find_child(section_name)
		if section:
			for child in section.get_children():
				if child is HBoxContainer:
					for button in child.get_children():
						if button is Button and button.name.ends_with("_Button"):
							var action = button.name.replace("_Button", "")
							action_buttons[action] = button
							button.pressed.connect(_on_button_clicked.bind(action))
							
func _update_button_labels():
	for action in action_buttons:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				for event in events:
					if event is InputEventKey:
						action_buttons[action].icon = load("res://assets/keyboard_keys/" + OS.get_keycode_string(event.keycode) + ".png")
						action_buttons[action].icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
						action_buttons[action].text = ""
						break

func _on_button_clicked(action):
	current_action = action

	set_process_input(true)

func _get_friendly_name(action):
	var name = action.replace("_", " ")
	var words = name.split(" ")
	for i in range(words.size()):
		if words[i].length() > 0:
			words[i] = words[i][0].to_upper() + words[i].substr(1)
	return " ".join(words)

func _input(event):
	if current_action != "":
		if event is InputEventKey and event.pressed:
			if event.keycode != KEY_ESCAPE:
				KeybindingSystem.update_input_map(current_action, event.keycode)
				
				action_buttons[current_action].icon = load("res://assets/keyboard_keys/" + OS.get_keycode_string(event.keycode) + ".png")
				action_buttons[current_action].icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				action_buttons[current_action].text = ""
				
				current_action = ""
				
				set_process_input(false)
				
				KeybindingSystem.save_keybindings()
				
				get_viewport().set_input_as_handled()
			else:
				get_viewport().set_input_as_handled()


func _on_reset_defaults():
	KeybindingSystem.initialize_default_bindings()
	KeybindingSystem.save_keybindings()
	
	_update_button_labels()