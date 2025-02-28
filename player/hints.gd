extends HFlowContainer

@onready var new_hint = preload("res://player/hint.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_hint(key: Key, tip: String) -> void:
	var hint = new_hint.instantiate()
	hint.key = key
	hint.tip = tip
	add_child(hint)

func remove_hint(key: Key) -> void:
	for child in get_children():
		if child.key == key:
			child.queue_free()
			return
