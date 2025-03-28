extends Node2D


func get_keybind_as_string(input_action: String) -> String:
	var events = InputMap.action_get_events(input_action)
	
	
	for event in events:
		if event is InputEventKey:
			return event.as_text()
			
		
	return "NULL"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$FirstCol.text = get_keybind_as_string("key1")
	$SecondCol.text = get_keybind_as_string("key2")
	$ThirdCol.text = get_keybind_as_string("key3")
	$FourthCol.text = get_keybind_as_string("key4")

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

func get_acc_sum():
	return $HUD.get_notes_sum()

func get_score() -> int:
	var text = $HUD/CanvasLayer/Score.text
	var score_text = text.strip_edges()  
	score_text = score_text.replace("[right]", "").replace("[/right]", "")
	return int(score_text)
	
func get_stats() -> Dictionary:
	# score
	var s_text = $HUD/CanvasLayer/Score.text
	var score_text = s_text.strip_edges()  
	score_text = score_text.replace("[right]", "").replace("[/right]", "")
	
	# accuracy
	var a_text = $HUD/CanvasLayer/Accuracy.text
	var accuracy_text = a_text.strip_edges()  
	accuracy_text = accuracy_text.replace("[right]", "").replace("[/right]", "")
	print('accuracy text', accuracy_text)
	
	# combo
	var c_text = $HUD/CanvasLayer/Accuracy.text
	var combo_text = c_text.strip_edges()  
	combo_text = combo_text.replace("[center]", "").replace("[/center]", "")
	
	
	return {
		"score": int(score_text),
		"accuracy": float(accuracy_text),
		"combo": int(combo_text)
	}
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
	
	
