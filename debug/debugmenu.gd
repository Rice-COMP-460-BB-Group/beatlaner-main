extends Control


var spawner_request: Dictionary = {}
var top_count = 0
var mid_count = 0
var low_count = 0


signal spawn_wave(spawn_request: Dictionary)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Disables enemy waves from spawning
func _on_check_box_toggled(toggled_on: bool) -> void:
	print("checked on!",toggled_on)
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
	print("here's the request!",spawner_request)
	spawn_wave.emit(spawner_request)


func _on_low_minion_count_value_changed(value: float) -> void:
	low_count = int(value)
	spawner_request["low"] = low_count
