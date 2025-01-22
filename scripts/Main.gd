extends Node2D

var map_scene = preload("res://map/Map.tscn")

var spawner_scene = load("res://minions/spawner.tscn")

func _ready():
	print("game started")
	
	spawner = get_node("Spawner")
	

	


func _on_debugmenu_send_wave(config: Dictionary, is_friendly: bool) -> void:
	
