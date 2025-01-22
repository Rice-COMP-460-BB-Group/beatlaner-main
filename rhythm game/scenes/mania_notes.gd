extends Sprite2D


func _init():
	# Debug texture and transparency
	self.modulate.a = 1.0  # Ensure fully opaque

	# Debugging helper for visibility
	var debug_rect = ColorRect.new()
	debug_rect.color = Color(1, 0, 0, 0.5)  # Semi-transparent red
	debug_rect.size = Vector2(50, 50)  # Adjust size to match note
	add_child(debug_rect)
	

	# Activate processing
	set_process(false)


@export var speed = 12.0
# 12 is best, 8 for casuals
var init_y = -370.0

var end = 290
var passed = false


func _process(delta):
	global_position += Vector2(0, speed)
	z_index = 100
	if global_position.y > end + 140:
		passed = true


func init(init_x):
	global_position = Vector2(init_x, init_y)
	set_process(true)



func _on_garbage_collector_timeout() -> void:
	queue_free()
