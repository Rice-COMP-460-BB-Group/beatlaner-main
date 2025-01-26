extends Node2D

class_name Tower

signal score
signal open_rhythm_game

enum Team {BLUE, RED}

@export var team: Team
@onready var popup_window = $Window
@onready var surrender_scene = preload("res://map/surrender.tscn")
var rhythm_game_instance

func _ready():
	
	$Sprite2D.centered = true
	popup_window.hide()
	popup_window.size = Vector2(1152, 648)


func _on_health_component_health_destroyed() -> void:
	var viewport = get_viewport()
	if $VisibleOnScreenNotifier2D.is_on_screen():
		var camera = viewport.get_camera_2d()
		if camera:
			camera.shake()
	var surrender_instance = surrender_scene.instantiate()
	get_parent().add_child(surrender_instance)
	surrender_instance.global_position = global_position

	Signals.TowerDestroyed.emit(team)
	queue_free()

func _on_button_pressed() -> void:
	Signals.OpenRhythmGame.emit(name)
