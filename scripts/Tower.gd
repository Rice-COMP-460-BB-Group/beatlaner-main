extends Node2D

class_name Tower

signal score

enum Team {BLUE, RED}

@export var team: Team
@onready var popup_window = $Window
@onready var surrender_scene = preload("res://map/surrender.tscn")
var rhythm_game_instance

func _ready():
	
	$Sprite2D.centered = true
	popup_window.hide()
	popup_window.size = Vector2(1152, 648)

func _process(delta):
	if len(popup_window.get_children()) and Input.is_action_just_pressed("escape rhythm game"):
		var score = rhythm_game_instance.get_score()
		Signals.Score.emit(score)
		popup_window.remove_child(rhythm_game_instance)
		popup_window.hide()


func _on_health_component_health_destroyed() -> void:
	var viewport = get_viewport()
	if $VisibleOnScreenNotifier2D.is_on_screen():
		var camera = viewport.get_camera_2d()
		if camera:
			camera.shake()
	var surrender_instance = surrender_scene.instantiate()
	get_parent().add_child(surrender_instance)
	$DestroySound.play()
	await $DestroySound.finished
	surrender_instance.global_position = global_position
	queue_free()

func _on_button_pressed() -> void:
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	rhythm_game_instance = rhythm_game_scene.instantiate()
	popup_window.add_child(rhythm_game_instance)
	popup_window.show()
