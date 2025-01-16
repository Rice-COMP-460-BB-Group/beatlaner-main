extends Camera2D


var drag_active = false
var last_mouse_pos = Vector2.ZERO

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        drag_active = event.pressed
        last_mouse_pos = event.position
    elif event is InputEventMouseMotion and drag_active:
        var delta = event.position - last_mouse_pos
        offset -= delta
        last_mouse_pos = event.pos

        
