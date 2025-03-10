extends HBoxContainer

@export var key: Key = 0
@export var tip: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Key.texture = load("res://assets/keyboard_keys/" + OS.get_keycode_string(key) + ".png")
	$Label.text = tip
