extends Node2D

var difficulty
enum Difficulty {EASY, MEDIUM, HARD}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("DIFF rhythm", difficulty)
	$"mania-key2".difficulty = difficulty
	$"mania-key3".difficulty = difficulty
	$"mania-key".difficulty = difficulty
	$"mania-key4".difficulty = difficulty
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_maniakey_hit(type: String) -> void:
	$Status.text = type

func get_score() -> int:
	var text = $HUD/CanvasLayer/Score.text
	var score_text = text.strip_edges()  
	score_text = score_text.replace("[right]", "").replace("[/right]", "")
	return int(score_text)
	
func get_combo() -> int:
	return $HUD.combo
	
	
