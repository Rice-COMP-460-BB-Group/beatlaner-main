extends Label

@export var critical: float = 0

func _ready():
	position = Vector2(-size.x / 2, -size.y / 2)
	
	var white = Color(1, 1, 1, 1)
	var yellow = Color(1, 1, 0, 1)
	var orange = Color(1, 0.5, 0, 1)
	var red = Color(1, 0, 0, 1)
	
	var final_color
	if critical < 0.5:
		final_color = white.lerp(yellow, critical * 2)
	elif critical < 0.75:
		final_color = yellow.lerp(orange, (critical - 0.5) * 4)
	else:
		final_color = orange.lerp(red, (critical - 0.75) * 4)
	
	modulate = final_color
	scale = Vector2.ONE * (1.0 + critical)

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)

	var dir = Vector2(0, -1).rotated(rotation)

	tween.tween_property(self, "position", position + dir * 30, 0.2)

	tween.tween_property(self, "position", position + dir * 40, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(self, "position", position + dir * 100, 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
	
	tween.tween_callback(queue_free)
