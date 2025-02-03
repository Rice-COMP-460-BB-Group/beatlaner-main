extends Control

func add_enemy_to_minimap(enemyPos: Vector2,team:bool):
	var icon = TextureRect.new()
	icon.texture = preload("res://assets/Blue-Team-Map.png")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(25, 25)  # Adjust size as needed
	print(enemyPos,"coordsy")
	icon.position = enemyPos
	print("added")
	$MinimapIcons.add_child(icon)

func world_to_minimap(world_pos: Vector2, world_size: Vector2, minimap_size: Vector2) -> Vector2:
	var x_ratio = minimap_size.x / world_size.x
	var y_ratio = minimap_size.y / world_size.y
	return Vector2(world_pos.x * x_ratio, world_pos.y * y_ratio)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func reset_map() -> void:
	for c in $MinimapIcons.get_children():
		$MinimapIcons.remove_child(c)
		c.queue_free()
		
	
func refresh_minimap(blue_team:Array,red_team:Array):
	reset_map()
	print("refresh_minimap",blue_team,red_team)
	for blue_pos in blue_team:
		var coords = world_to_minimap(blue_pos,Vector2(4096,4096),Vector2(216,216))
		print(coords,"coords")
		add_enemy_to_minimap(coords,true)
	for red_pos in red_team:
		var coords = world_to_minimap(red_pos,Vector2(4096,4096),Vector2(216,216))
		add_enemy_to_minimap(coords,false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
