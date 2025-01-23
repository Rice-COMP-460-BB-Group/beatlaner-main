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
func freeze_current_enemies(duration: int,lane: int,team: int) ->void:
	if true:
		var bodies = mid.get_overlapping_bodies()
		print(bodies.size(),"current enemies")
		for b in bodies:
			if b.has_method("process_status"):
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
