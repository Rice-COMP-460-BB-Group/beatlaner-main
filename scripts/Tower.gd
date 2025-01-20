extends Node2D

@export var max_health: int = 100
var current_health: int
signal health_changed(current_health, max_health)

func _ready():
	position = get_viewport_rect().size / 2
	$Sprite2D.centered = true
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pos = $Sprite2D.to_local(event.position)
		if $Sprite2D.get_rect().has_point(local_pos):
			take_damage(10)

func take_damage(amount):
	current_health = max(current_health - amount, 0)
	print("tower hp:", current_health)
	emit_signal("health_changed", current_health, max_health)
