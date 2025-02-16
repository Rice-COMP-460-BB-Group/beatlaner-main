extends Control


var spawner_request: Dictionary = {}
var top_count = 0
var mid_count = 0
var low_count = 0


signal spawn_wave(spawn_request: Dictionary, is_friendly: bool)
signal freeze_spell(lane: int, friendly: bool)

signal toggle_enemy_wave(state: bool)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	hide()

func _input(event: InputEvent):
	
	if Input.is_key_pressed(KEY_Q):
		visible = !visible
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Disables enemy waves from spawning
func _on_check_box_toggled(toggled_on: bool) -> void:
	print("[debugmenu.gd]","checked on!", toggled_on)
	toggle_enemy_wave.emit(toggled_on)
	pass # Replace with function body.

	
func _on_top_minion_count_value_changed(value: float) -> void:
	top_count = int(value)
	spawner_request["top"] = top_count
	 # Replace with function body.


func _on_mid_minion_count_value_changed(value: float) -> void:
	mid_count = int(value)
	spawner_request["mid"] = mid_count
	pass # Replace with function body.

#submitting a request for spawn waves
func _on_button_pressed() -> void:
	
	spawn_wave.emit(spawner_request, true)


func _on_low_minion_count_value_changed(value: float) -> void:
	low_count = int(value)
	spawner_request["low"] = low_count


func _on_button_2_pressed() -> void:
	freeze_spell.emit(0, 0)

#freeze middle
func _on_button_3_pressed() -> void:
	freeze_spell.emit(1, 0)

#freeze bottom
func _on_button_4_pressed() -> void:
	freeze_spell.emit(2, 0)
