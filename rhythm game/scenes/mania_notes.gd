class_name ManiaNote
extends Sprite2D
func _ready():
	self_modulate.a = .35
func _init():
	# Activate processing
	set_process(false)


#@export var speed = 8.00
@export var speed = 12.00


# 12 is best, 8 for casuals
var init_y = -370.0

var end = 260
var passed = false


func _process(delta):
	global_position += Vector2(0, speed) * delta * 100
	z_index = 100
	if global_position.y > end + 140:
		passed = true
	

func init(init_x, new_speed: float):
	global_position = Vector2(init_x, init_y)
	speed = new_speed
	set_process(true)

func set_light(keyNum: int):
	if keyNum == 1:
		$PointLight2D.color = Color(105, 54, 245)
	elif keyNum == 2:
		$PointLight2D.color = Color(255, 86, 22)
	elif keyNum == 3:
		$PointLight2D.color = Color(0, 250, 163)
	else:
		$PointLight2D.color = Color(253, 6, 233)
		
		
func _on_garbage_collector_timeout() -> void:
	queue_free()
