extends Node2D

class_name Tower

enum Team {BLUE, RED}

@export var team: Team
@onready var popup_window = $Window
@onready var surrender_scene = preload("res://map/surrender.tscn")

func _ready():
	
	$Sprite2D.centered = true

func _on_health_component_health_destroyed() -> void:
	var surrender_instance = surrender_scene.instantiate()
	get_parent().add_child(surrender_instance)
	$DestroySound.play()
	await $DestroySound.finished
	surrender_instance.global_position = global_position
	queue_free()

func _on_button_pressed() -> void:
	var rhythm_game_scene = load("res://rhythm game/scenes/background.tscn")
	var rhythm_game_instance = rhythm_game_scene.instantiate()
	popup_window.size = Vector2(1152, 648)
	popup_window.add_child(rhythm_game_instance)
	popup_window.popup_centered()
