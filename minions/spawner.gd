extends Node2D
@export var friendly_wave_config: Dictionary = {"top": 1, "mid": 1, "bottom": 1}
@export var enemy_wave_config: Dictionary = {"top": 1, "mid": 1, "bottom": 1}
var to_add: Dictionary = {"top": 0, "mid": 0, "bottom": 0}

var minionScene = load("res://minions/minion.tscn")
var mageScene = load("res://minions/mage.tscn")
@onready var multiplayer_spawner = get_parent().get_node("MultiplayerSpawner")  # Access sibling
var towerScene = load("res://main/Tower.tscn")
var minion_count = 0
var to_spawn = 1
var spawn_points = {}

@onready var upperThrough: Marker2D = $UpperThrough
@onready var lowerThrough: Marker2D = $LowerThrough
@onready var enemySpawnTimer: Timer = $WaveTimer

var type_to_config = {
	"Lower": "bottom",
	"Mid": "mid",
	"Upper": "top"
}

func Score(new_score: int, tower_type: String):
	print(new_score, tower_type, enemy_wave_config)
	var key = tower_type.substr(2, tower_type.length())
	print('bruh', new_score, tower_type)
	var additional_minions = int(pow(new_score / 10000.0, 0.6))
	to_add[type_to_config[key]] += additional_minions
	print("real minion count", to_add[type_to_config[key]])
	print(type_to_config[key], enemy_wave_config)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MultiplayerSpawner.spawn_function = spawn

	if not multiplayer.is_server():
		return
	Signals.Score.connect(Score)
	print("spawner invoked")
	# $MultiplayerSpawner.set_spawn_function(spawn)
		
func spawner_init() -> void:
	for sp in get_children():
		if sp is Marker2D:
			if sp.name == "UpperThrough" or sp.name == "LowerThrough":
				continue
			var tower = towerScene.instantiate()
			tower.position = sp.position
			tower.team = sp.name.find("P1") == 0
			tower.name = sp.name
			print(tower.name)
			spawn_points[sp.name] = tower
			var main = get_parent()
			main.add_child(tower)

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

func disable_timer() -> void:
	print("timer disabled!!")
	enemySpawnTimer.stop()

func enable_timer() -> void:
	print("timer enabled!!")
	enemySpawnTimer.start()
	

#func spawn_friendly_wave(config: Dictionary,is_friendly: bool) -> void:
	#print("config dict is",config)
	#var player = "P1" if is_friendly else "P2"
	#if "top" in config:    
		#topcount = config["top"]
	#if "mid" in config:
		#midcount = config["mid"]
	#if "low" in config:
		#bottomcount = config["low"]
	#var top_minions = []
	#
	#for i in range(topcount):
		#top_minions.append(spawn_minion(player+"Upper"))
	#
	#var mid_minions = []
	#
	#for i in range(midcount):
		#
		#mid_minions.append(spawn_minion(player+"Mid"))
	#var bottom_minions = []
	#for i in range(bottomcount):    
		#bottom_minions.append(spawn_minion(player+"Lower"))
	#var main = get_parent()
	#for m in top_minions:
		#main.add_child(m)
	#for m in mid_minions:
		#main.add_child(m)
	#for m in bottom_minions:
		#main.add_child(m)

#func _on_timer_timeout() -> void:
	#print("timeout!!!")
	#spawn_friendly_wave(enemy_wave_config, false)

var topcount = 0
var midcount = 0
var bottomcount = 0


#func spawn_minion(key: String):
	#var spawnpt = spawn_points[key]
	#print(spawnpt, "heelo")
	#if !is_instance_valid(spawnpt):
		#return
#
	#var minion
	#if randi() % 2 == 0:
		#minion = minionScene.instantiate()
	#else:
		#minion = mageScene.instantiate()
	#if key.ends_with("Upper"):
		#minion.intermediate_lane = upperThrough
	#elif key.ends_with("Lower"):
		#minion.intermediate_lane = lowerThrough
	#minion.set_team(spawnpt.team == 0)
	#minion.tower_target = get_opposite(key)
	#minion.position = spawnpt.position
	#var main = get_parent()
	#main.add_child(minion)
	#minion_count += 1
	##main.add_child(minion)
	##minion_count += 1
	#
	
func spawn(dict):
	print("id: ", multiplayer.get_unique_id(), multiplayer.get_remote_sender_id())
	var key = dict["key"]
	var minion_type = dict["minion_type"]
	print('SPAWNING COPE', key, minion_type)
	var spawnpt = spawn_points.get(key, null)
	if not is_instance_valid(spawnpt):
		return

	var team = spawnpt.team
	
	# Get the opposite tower's name instead of the tower itself
	var tower_target_name = ""
	var opposite_tower = get_opposite(key)
	if is_instance_valid(opposite_tower):
		tower_target_name = opposite_tower.name

	# Spawn on server
	var minion = minionScene.instantiate() if minion_type else mageScene.instantiate()
	
	if key.ends_with("Upper"):
		minion.intermediate_lane = upperThrough
	elif key.ends_with("Lower"):
		minion.intermediate_lane = lowerThrough

	minion.set_team(team == 0)
	minion.tower_target = opposite_tower
	minion.position = spawnpt.position

	return minion

#func spawn_minion_on_clients(key: String, minion_type: int, position: Vector2, team: int, tower_target_name: String):
	# This method is called on clients to spawn minions
	#$MultiplayerSpawner.spawn(spawn(key, position, minion_type))
func _spawn_and_sync(key: String):
	# Sync spawn to all clients
	var minion_type = randi() % 2
	print("cope vope spawn", multiplayer.get_unique_id())
	
	$MultiplayerSpawner.spawn({"key": key, "minion_type": minion_type})
	#spawn_minion_on_clients.rpc(key, minion_type, spawnpt.position, team, tower_target_name)

func spawn_friendly_wave(config: Dictionary, is_friendly: bool) -> void:
	print("spawning spawning", config)
	if not multiplayer.is_server():
		return  # Only the server triggers spawning

	var player = "P1" if is_friendly else "P2"

	for _i in range(config.get("top", 0) + to_add["top"]):
		_spawn_and_sync(player + "Upper")

	for _i in range(config.get("mid", 0) + to_add["mid"]):
		_spawn_and_sync(player + "Mid")

	for _i in range(config.get("bottom", 0) + to_add["bottom"]):
		_spawn_and_sync(player + "Lower")
@rpc("authority")
func _on_wave_timer_timeout() -> void:
	if not multiplayer.is_server():
		return
	print('ran')
	spawn_friendly_wave(friendly_wave_config, true)
	spawn_friendly_wave(enemy_wave_config, false)
	to_add = {"top": 0, "mid": 0, "bottom": 0}
