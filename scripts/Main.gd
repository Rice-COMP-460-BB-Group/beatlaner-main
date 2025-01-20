extends Node2D

var map_scene = preload("res://map/Map.tscn")

var spawner_scene = load("res://minions/spawner.tscn")

func _ready():
	print("game started")
	var map = map_scene.instantiate()
	var spawner = spawner_scene.instantiate()
	add_child(map)
	add_child(spawner)
	

	
