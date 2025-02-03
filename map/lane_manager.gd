extends Node

@onready var top: Area2D = $"../UpperLane"
@onready var mid: Area2D = $"../MidLane"
@onready var lower: Area2D = $"../LowerLane"
@onready var map: Area2D = $"../MapPosHandler"


	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#
func freeze_current_enemies(lane: int,team: int) ->void:
	
	var bodies = []
	if lane == 0:
		bodies = top.get_overlapping_bodies()
		
	elif lane == 1:
		bodies = mid.get_overlapping_bodies()
	elif lane == 2:
		bodies = lower.get_overlapping_bodies()
	print("here are bodies:",bodies)
	for b in bodies:
			if b.has_method("process_status") and b.has_method("get_team"):
				print("a minoiin!",b.get_team())
				if b.get_team() == 0:
					
					b.process_status("freeze")
	
func _on_lower_lane_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return 
	print(body.name)

func _on_lower_lane_body_exited(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return# Replace with function body.
	print(body.name)

func _on_mid_lane_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return # Replace with function body.
	print(body.name)

func _on_mid_lane_body_exited(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return# Replace with function body.
	print(body.name)

func _on_upper_lane_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return # Replace with function body.
	print(body.name)

func _on_upper_lane_body_exited(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return
	print(body.name)


func _on_player_wave_request(pos: int, size: int) -> void:
	var spawner = $"../../Spawner"
	var config = {"top": 0,"mid":0, "bottom":0}
	if pos == 0:
		config["top"] = 5
	if pos == 1:
		config["mid"] = 5
	if pos == 2:
		config["low"] = 5
	spawner.spawn_friendly_wave(config, true)
		
#retrieves the positions of all minions currently on the map
func get_minimap_info() ->Dictionary :
	var current_blue = []
	
	var current_red = []
	var bodies = map.get_overlapping_bodies()
	print("bodies",bodies)
	for b in bodies:
		print("hello from bodies!")
		if b.name == "Player":
			current_blue.append(b.position)
		if b.has_method("get_team"):
			
			if b.get_team() == 0:
				current_blue.append(b.position)
			if b.get_team() == 1:
				current_blue.append(b.position)
				
	print("current_blue",current_blue,"current_red",current_red)
	return {"blue":current_blue,"red":current_red}
	
	
	
	
