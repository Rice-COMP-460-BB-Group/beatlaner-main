extends Sprite2D
var shadows : Array[Sprite2D] = []
@export var modulate_config : Vector4 = Vector4(0, 0, 0, 0.6)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var image = texture.get_image()
	var image_texture = ImageTexture.create_from_image(image)
	
	var total_frames = int(texture.get_width() / 74.0)
	for frame_index in range(total_frames):
		var shadow = Sprite2D.new()
		shadow.texture = image_texture
		shadow.region_enabled = true
		shadow.region_rect = Rect2(frame_index * 74, 0, 74, 83)
		shadow.flip_h = flip_h
		shadow.flip_v = true
		shadow.position.y = 59
		shadow.position.x = -36
			
		shadow.modulate.r=modulate_config[0]
		shadow.modulate.g=modulate_config[1]
		shadow.modulate.b=modulate_config[2]
		shadow.modulate.a=modulate_config[3]
		shadow.skew = 1
		shadows.append(shadow)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
