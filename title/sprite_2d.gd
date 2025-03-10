extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	glow()

var incr_ct = 0

var should_incr = true
func glow() -> void:
	var t = create_tween()
	t.connect("finished",Callable(self,"tweenFinished"))
	t.tween_property(self,"self_modulate",Color(2,2,2),.5)
	t.chain().tween_property(self,"self_modulate",Color(3,3,3),.5)
func tweenFinished() -> void:
	glow()
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
