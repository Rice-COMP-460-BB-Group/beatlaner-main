extends Node2D


var minionScene = load("res://minions/minion.tscn")

var towerScene = load("res://main/Tower.tscn")
var minion_count = 0
var spawn_points = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawner invoked")
	for sp in get_children():
		if sp is Marker2D:
			var tower = towerScene.instantiate()
			tower.position = sp.position
			tower.team = sp.name.find("P1") == 0
			tower.name = sp.name
			spawn_points[sp.name] = tower
			var main = get_parent()
			main.add_child(tower)
		
		
	 # Replace with function body.

func get_opposite(key: StringName) -> Tower:
	if key == "P1Lower":
		if is_instance_valid(spawn_points["P2Lower"]):
			return spawn_points["P2Lower"]
		elif is_instance_valid(spawn_points["P2Mid"]):
			return spawn_points["P2Mid"]
		elif is_instance_valid(spawn_points["P2Upper"]):
			return spawn_points["P2Upper"]
		else:
			return null
	elif key == "P1Mid":
		if is_instance_valid(spawn_points["P2Mid"]):
			return spawn_points["P2Mid"]
		elif is_instance_valid(spawn_points["P2Lower"]):
			return spawn_points["P2Lower"]
		elif is_instance_valid(spawn_points["P2Upper"]):
			return spawn_points["P2Upper"]
		else:
			return null
	elif key == "P1Upper":
		if is_instance_valid(spawn_points["P2Upper"]):
			return spawn_points["P2Upper"]
		elif is_instance_valid(spawn_points["P2Mid"]):
			return spawn_points["P2Mid"]
		elif is_instance_valid(spawn_points["P2Lower"]):
			return spawn_points["P2Lower"]
		else:
			return null
	elif key == "P2Lower":
		if is_instance_valid(spawn_points["P1Lower"]):
			return spawn_points["P1Lower"]
		elif is_instance_valid(spawn_points["P1Mid"]):
			return spawn_points["P1Mid"]
		else:
			return spawn_points["P1Upper"]
	elif key == "P2Mid":
		if is_instance_valid(spawn_points["P1Mid"]):
			return spawn_points["P1Mid"]
		elif is_instance_valid(spawn_points["P1Lower"]):
			return spawn_points["P1Lower"]
		else:
			return spawn_points["P1Upper"]
	elif key == "P2Upper":
		if is_instance_valid(spawn_points["P1Upper"]):
			return spawn_points["P1Upper"]
		elif is_instance_valid(spawn_points["P1Mid"]):
			return spawn_points["P1Mid"]
		elif is_instance_valid(spawn_points["P1Lower"]):
			return spawn_points["P1Lower"]
		else:
			return null
	else:
		return null

func spawn_minion():
	minionScene.instantiate()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_timer_timeout() -> void:
	var key = spawn_points.keys()[randi() % spawn_points.size()]
	var spawnpt = spawn_points[key]
	if !is_instance_valid(spawnpt):
		return
	var minion = minionScene.instantiate()
	minion.set_team(spawnpt.team == 0)
	minion.tower_target = get_opposite(key)
	minion.position = spawnpt.position

	var main = get_parent()
	main.add_child(minion)
	minion_count += 1
