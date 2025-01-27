extends PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_flicker_timeout() -> void:
	energy = randf() * .1 + 1
	scale = Vector2(1, 1) * energy
