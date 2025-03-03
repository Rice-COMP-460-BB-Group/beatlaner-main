extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FirstCol.text = OS.get_keycode_string(KeybindingSystem.action_bindings["first_key"])
	$SecondCol.text = OS.get_keycode_string(KeybindingSystem.action_bindings["second_key"])
	$ThirdCol.text = OS.get_keycode_string(KeybindingSystem.action_bindings["third_key"])
	$FourthCol.text = OS.get_keycode_string(KeybindingSystem.action_bindings["fourth_key"])

enum diff {EASY=0,MEDIUM=1,HARD=2}
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_maniakey_hit(type: String) -> void:
	$Status.text = type

func is_dead():
	$HUD.is_dead = true
func is_alive():
	$HUD.is_dead = false

func get_score() -> int:
	var text = $HUD/CanvasLayer/Score.text
	var score_text = text.strip_edges()  
	score_text = score_text.replace("[right]", "").replace("[/right]", "")
	return int(score_text)
func reset_score() -> void:
	$HUD.reset()
func disable() -> void:
	$ManiaKey.is_enabled = false
	
	$ManiaKey2.is_enabled = false
	$ManiaKey3.is_enabled = false
	$ManiaKey4.is_enabled = false
	$HUD/CanvasLayer.hide()
	$HUD.enabled = false

func enable() -> void:
	$ManiaKey.is_enabled = true
	$ManiaKey2.is_enabled = true
	$ManiaKey3.is_enabled = true
	$ManiaKey4.is_enabled = true
	$HUD/CanvasLayer.show()
	$HUD.enabled = true

func set_difficulty(d: diff) -> void:
	$ManiaKey.difficulty = d
	
	$ManiaKey2.difficulty = d
	$ManiaKey3.difficulty = d
	$ManiaKey4.difficulty = d
	
func get_combo() -> int:
	return $HUD.combo
	
	
