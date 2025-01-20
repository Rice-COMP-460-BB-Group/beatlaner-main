extends Node2D






var minionScene = load("res://minions/minion.tscn")
var minion_count = 0
var spawn_points := []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawner invoked")
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)
	
		
	 # Replace with function body.




func spawn_minion():
	minionScene.instantiate()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_timer_timeout() -> void:
	print("timeout!")
	if minion_count < 1:
		var spawnpt = spawn_points[randi() % spawn_points.size()]
		var minion = minionScene.instantiate()
		minion.position = spawnpt.position
		var main = get_parent()
		main.add_child(minion)
		minion_count += 1
	
