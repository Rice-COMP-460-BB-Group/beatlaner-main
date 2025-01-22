extends Node2D


var minionScene = load("res://minions/minion.tscn")

var towerScene = load("res://main/Tower.tscn")
var minion_count = 0
var spawn_points = {}

@onready var upperThrough: Marker2D = $UpperThrough
@onready var lowerThrough: Marker2D = $LowerThrough

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawner invoked")
	for sp in get_children():
		if sp is Marker2D:
			if sp.name == "UpperThrough" or sp.name == "LowerThrough":
				continue
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
		elif is_instance_valid(spawn_points["P1Upper"]):
			return spawn_points["P1Upper"]
		else:
			return null
	elif key == "P2Mid":
		if is_instance_valid(spawn_points["P1Mid"]):
			return spawn_points["P1Mid"]
		elif is_instance_valid(spawn_points["P1Lower"]):
			return spawn_points["P1Lower"]
		elif is_instance_valid(spawn_points["P1Upper"]):
			return spawn_points["P1Upper"]
		else:
			return null
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


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_timer_timeout() -> void:
	var key = spawn_points.keys()[randi() % spawn_points.size()]
	var spawnpt = spawn_points[key]
	if !is_instance_valid(spawnpt):
		return
	var minion = minionScene.instantiate()
	if key.ends_with("Upper"):
		minion.intermediate_lane = upperThrough
	elif key.ends_with("Lower"):
		minion.intermediate_lane = lowerThrough
	minion.set_team(spawnpt.team == 0)
	minion.tower_target = get_opposite(key)
	minion.position = spawnpt.position

	var main = get_parent()
	main.add_child(minion)
	minion_count += 1

var num_enemy_upper = 0
var num_enemy_mid = 0
var num_enemy_lower = 0

func disable_enemy_spawns():
	print("pass")


func spawn_minion(key: String):
	var spawnpt = spawn_points[key]
	if !is_instance_valid(spawnpt):
		return
	var minion = minionScene.instantiate()
	if key.ends_with("Upper"):
		minion.intermediate_lane = upperThrough
	elif key.ends_with("Lower"):
		minion.intermediate_lane = lowerThrough
	minion.set_team(spawnpt.team == 0)
	minion.tower_target = get_opposite(key)
	minion.position = spawnpt.position

	return minion
	#main.add_child(minion)
	#minion_count += 1
	

func spawn_friendly_wave(config: Dictionary) -> void:
	
	var topcount = config["top"]
	
	var midcount = config["mid"]
	
	var bottomcount = config["bottom"]
	
	var top_minions = []
	
	for i in range(topcount):
		top_minions.append(spawn_minion("P1Upper"))
	
	var mid_minions = []
	for i in range(midcount):
		mid_minions.append(spawn_minion("P1Mid"))
	var bottom_minions = []
	for i in range(bottomcount):
		bottom_minions.append(spawn_minion("P1Lower"))
	var main = get_parent()
	for m in top_minions:
		main.addchild(m)
	
	for m in mid_minions:
		main.addchild(m)
	
	for m in bottom_minions:
		main.addchild(m)
		
	
