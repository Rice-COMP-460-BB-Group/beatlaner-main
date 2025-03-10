extends TextureRect

@onready var minimap_icons = "$../MinimapIcons"
func world_to_minimap(world_pos: Vector2, world_size: Vector2, minimap_size: Vector2) -> Vector2:
	var x_ratio = minimap_size.x / world_size.x
	var y_ratio = minimap_size.y / world_size.y
	return Vector2(world_pos.x * x_ratio, world_pos.y * y_ratio)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
