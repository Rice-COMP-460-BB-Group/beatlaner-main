extends TextureRect

var time = 0.0
var hover_offset = 0.0
var hover_speed = 0.7 # Slower speed for larger logo
var hover_amount = 15.0 # Increased amount for larger logo
var original_position = Vector2.ZERO

func _ready():
    original_position = position
    # Start periodic pulsing animation
    var pulse_timer = Timer.new()
    add_child(pulse_timer)
    pulse_timer.wait_time = 7.0 # Longer interval for larger logo
    pulse_timer.timeout.connect(pulse_animation)
    pulse_timer.start()
    
    # Add initial animation
    pulse_animation()

func _process(delta):
    time += delta
    # Add subtle floating motion
    hover_offset = sin(time * hover_speed) * hover_amount
    position.y = original_position.y + hover_offset

func pulse_animation():
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.8)
    tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8)
