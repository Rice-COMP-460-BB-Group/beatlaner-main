extends Sprite2D


func _init():
	set_process(false)


@export var speed = 12.0
# 12 is best, 8 for casuals
var init_y = -370.0

var end = 290
var passed = false


func _process(delta):
	global_position += Vector2(0, speed)

	if global_position.y > end + 140:
		passed = true


func init(init_x):
	global_position = Vector2(init_x, init_y)
	set_process(true)


func _on_garbage_collector_timeout() -> void:
	queue_free()
