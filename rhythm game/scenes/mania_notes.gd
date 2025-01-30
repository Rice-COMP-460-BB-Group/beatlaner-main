extends Sprite2D


func _init():
	# Activate processing
	set_process(false)


@export var speed = 8.00
#@export var speed = 12.00


# 12 is best, 8 for casuals
var init_y = -370.0

var end = 280
var passed = false


func _process(delta):
	global_position += Vector2(0, speed)
	z_index = 100
	if global_position.y > end + 140:
		passed = true
	


func init(init_x, new_speed: float):
	global_position = Vector2(init_x, init_y)
	speed = new_speed
	set_process(true)



func _on_garbage_collector_timeout() -> void:
	queue_free()
