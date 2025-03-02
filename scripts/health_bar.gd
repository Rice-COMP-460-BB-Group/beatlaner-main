extends TextureProgressBar

func _ready():
	value = 100

func update(new_health, max_health):
	var percent = float(new_health) / float(max_health) * 100.0
	value = percent

func incresae_Health(new_health):
	value = 100
