extends Node2D

var map_scene = preload("res://map/Map.tscn")
var camera_scene = preload("res://camera/mainCamera.tscn")

func _ready():
	print("game started")
	var map = map_scene.instantiate()
	var cam = camera_scene.instantiate()
	add_child(map)
	add_child(cam)

	
