extends Control

var topct: int = 0
var midct: int = 0
var loct: int = 0

signal send_wave(config:Dictionary,is_friendly:bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enable_enemy_waves_toggled(toggled_on: bool) -> void:
	
	pass # Replace with function body.


func _on_top_minion_count_value_changed(value: float) -> void:
	topct = int(value)
	pass # Replace with function body.


func _on_mid_minion_count_value_changed(value: float) -> void:
	midct = int(value)
	pass # Replace with function body.


func _on_low_minion_count_value_changed(value: float) -> void:
	loct = int(value)
	pass # Replace with function body.


func _on_button_pressed() -> void:
	var config = {"top":topct,"mid":midct,"lo":loct}
	send_wave.emit(config,true)
