extends Node2D


var minionScene = load("res://minions/minion.tscn")
var minion_count = 0
var spawn_points = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawner invoked")
	for i in get_children():
		if i is Marker2D:
			spawn_points[i.name] = i
	
		
	 # Replace with function body.

func get_opposite(marker: Marker2D) -> Marker2D:
	if marker.name == "P1Lower":
		return spawn_points["P2Lower"]
	elif marker.name == "P2Lower":
		return spawn_points["P1Lower"]
	elif marker.name == "P1Upper":
		return spawn_points["P2Upper"]
	elif marker.name == "P2Upper":
		return spawn_points["P1Upper"]
	elif marker.name == "P1Mid":
		return spawn_points["P2Mid"]
	elif marker.name == "P2Mid":
		return spawn_points["P1Mid"]
	else:
		return null

func spawn_minion():
	minionScene.instantiate()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_timer_timeout() -> void:
	print("timeout!")
	if minion_count < 1:
		var spawnpt = spawn_points[spawn_points.keys()[randi() % spawn_points.size()]]
		var minion = minionScene.instantiate()
		minion.target = get_opposite(spawnpt)
		minion.position = spawnpt.position
		
		var main = get_parent()
		main.add_child(minion)
		minion_count += 1
