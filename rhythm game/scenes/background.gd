extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_maniakey_hit(type: String) -> void:
	print('received', type)
	$Status.text = type


func _on_maniakey_2_hit(extra_arg_0: String) -> void:
	pass # Replace with function body.


func _on_maniakey_3_hit(extra_arg_0: String) -> void:
	pass # Replace with function body.


func _on_maniakey_4_hit(extra_arg_0: String) -> void:
	pass # Replace with function body.
