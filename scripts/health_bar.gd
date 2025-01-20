extends TextureProgressBar

func _ready():
	value = 100

func _on_tower_health_changed(new_health, max_health):
	var percent = float(new_health) / float(max_health) * 100.0
	value = percent
