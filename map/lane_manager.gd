extends Node

@onready var top: Area2D = $"../UpperLane"
@onready var mid: Area2D = $"../MidLane"
@onready var lower: Area2D = $"../LowerLane"

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
	
func damage_powerup(team: int) ->void:
	
	var bodies = top.get_overlapping_bodies()
	bodies += mid.get_overlapping_bodies()
	bodies += lower.get_overlapping_bodies()
	print("here are bodies:",bodies)
	for b in bodies:
		if b.has_method("process_damage_powerup") and b.has_method("get_team"):
			print("a minoiin!",b.get_team())
			if b.get_team() == 1:
				
				b.process_damage_powerup()
					
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
