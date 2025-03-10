extends Node2D

@export var fade_duration: float = 0.3
@export var velocity: Vector2 = Vector2.ZERO

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), fade_duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(queue_free)
	
func _process(delta):
	position += velocity * delta  # If you want afterimages to move slightly
