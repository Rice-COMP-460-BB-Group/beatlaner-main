extends Node2D
@onready var lane_manager = $Map/LaneManager
var map_scene = preload("res://map/Map.tscn")

var spawner_scene = load("res://minions/spawner.tscn")

var spawner = null

func _ready():
	print("game started")
	
	spawner = get_node("Spawner")
	spawner.spawner_init()
	
	
	
	


func _on_debugmenu_spawn_wave(spawn_request: Dictionary,is_friendly: bool) -> void:
	
	print(spawn_request,"here from main!")
	print(spawner)
	if spawner:
		
		spawner.spawn_friendly_wave(spawn_request,is_friendly)


func _on_debugmenu_toggle_enemy_wave(state: bool) -> void:
	
	if state:
		spawner.enable_timer()
	else:
		spawner.disable_timer()
	pass # Replace with function body.


func _on_debugmenu_freeze_spell(lane: int, friendly: bool) -> void:
	print("calling freeze")
	lane_manager.freeze_current_enemies(lane,0) # Replace with function body.
