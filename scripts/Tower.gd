extends Node2D

class_name Tower

enum Team {BLUE, RED}

@export var team: Team

func _ready():
	
	$Sprite2D.centered = true

func _on_health_component_health_destroyed() -> void:
	$DestroySound.play()
	await $DestroySound.finished
	queue_free()