extends Node2D

@export var max_health: int = 100
var current_health: int

func _ready():
	current_health = max_health
	print("Tower ready with health:", current_health)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse button pressed!")
		if event.button_index == MOUSE_BUTTON_LEFT:
			var sprite = $Sprite2D
			var local_mouse_pos = sprite.to_local(get_global_mouse_position())
			if sprite.texture and sprite.texture.get_size().x > 0 and sprite.texture.get_size().y > 0:
				var half_width = sprite.texture.get_size().x * 0.5
				var half_height = sprite.texture.get_size().y * 0.5
				if abs(local_mouse_pos.x) < half_width and abs(local_mouse_pos.y) < half_height:
					print("Click detected on sprite!")
					handle_click()


func handle_click():
	decrement_health(1)

func decrement_health(amount: int):
	current_health -= amount
	print("Tower health is now:", current_health)
	if current_health <= 0:
		print("Tower destroyed!")
		queue_free()
