extends PointLight2D

@onready var tween: Tween

func _ready() -> void:
	pass

func _on_flicker_timeout() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	# Create new tween
	tween = create_tween()
	
	# Random target values
	var target_energy = randf() * .1 + 1
	var target_scale = Vector2(1, 1) * target_energy
	
	# Animate both properties
	tween.set_parallel(true)
	tween.tween_property(self, "energy", target_energy, 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_CUBIC)
