extends Sprite2D

signal hit

@onready var note = preload("res://rhythm game/scenes/mania_notes.tscn")

@export var key = ""

var active_notes = []

func _ready():
	$ActiveKey.hide()

func _process(delta):
	

	if Input.is_action_just_pressed(key):
		$ActiveKey.show()
		$ActiveKeyTimer.start()
		$Kicksound1.play()
		
	
	if active_notes:
		if active_notes and Input.is_action_just_pressed(key):
			var front_note = active_notes.front()
			var distance_at_click = abs(front_note.global_position.y - front_note.end)
			if distance_at_click < 180:
				active_notes.pop_front()
				front_note.queue_free()
				if distance_at_click < 20:
					Signals.Hit.emit('Perfect')
				elif distance_at_click < 50:
					Signals.Hit.emit('Good')
				elif distance_at_click < 80:
					Signals.Hit.emit('Ok')
				elif distance_at_click < 130:
					Signals.Hit.emit('Bad')
				else:
					Signals.Hit.emit('Miss')

		if active_notes and is_instance_valid(active_notes.front()) and active_notes.front().passed:
			active_notes.pop_front()
			Signals.Hit.emit('Miss')
	
func init():
	var new_note = note.instantiate()
	if key == "key2":
		new_note.texture = load("res://rhythm game/assets/mania_notes/Sigil2.png")
	elif key == "key3":
		new_note.texture = load("res://rhythm game/assets/mania_notes/Sigil3.png")
	elif key == "key4":
		new_note.texture = load("res://rhythm game/assets/mania_notes/Sigil4.png")
	get_parent().add_child(new_note)
	new_note.init(position.x)
	active_notes.push_back(new_note)


func _on_rand_timer_timeout() -> void:
	if randi_range(0, 2) == 0:
		init()
	#$RandTimer.wait_time = randf_range(0.1, 0.5) # hard
	#$RandTimer.wait_time = randf_range(0.1, 0.8) # medium
	#$RandTimer.wait_time = randf_range(0.5, 2.0) # easy
	
	$RandTimer.wait_time = 0.5
	$RandTimer.start()

func _on_active_key_timer_timeout() -> void:
	$ActiveKey.hide()
