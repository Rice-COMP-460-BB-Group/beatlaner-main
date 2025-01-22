extends Node2D

var map_scene = preload("res://map/Map.tscn")

var spawner_scene = load("res://minions/spawner.tscn")

var spawner = null

func _ready():
	print("game started")
	
	
	var map = map_scene.instantiate()
	spawner = spawner_scene.instantiate()
	add_child(map)
	add_child(spawner)
	
	

	


func _on_debugmenu_spawn_wave(spawn_request: Dictionary) -> void:
	
	print(spawn_request,"here from main!")
	print(spawner)
	if spawner:
		
		spawner.spawn_enemy_wave(spawn_request)
