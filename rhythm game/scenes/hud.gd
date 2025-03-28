extends Control

var type = ""
var score = 0
var acc_notes_sum = 0
var acc_notes_total = 0
var combo = 0
@export var enabled = false
var points_dict = {
	"Perfect": 300,
	"Good": 200,
	"Ok": 100,
	"Bad": 50,
	"Miss": 0
}


var accuracy_dict = {
	"Perfect": 100,
	"Good": 66,
	"Ok": 50,
	"Bad": 33,
	"Miss": 0
}

var is_dead = false

var tween = null
func reset():
	acc_notes_sum = 0
	acc_notes_total = 0
	combo = 0
	score = 0
	%Accuracy.text = "[right]" + "0.00" + "%" + "[/right]"
	%Combo.text = "[center]"+str(combo)+"[/center]" if combo else ""
	%Score.text = "[right]" + str(score) + "[/right]"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.Hit.connect(Hit)
	Signals.ScrollSpeedChange.connect(ScrollSpeedChange)

func ScrollSpeedChange(speed: float):
	%ScrollSpeed.text = "[center]　New Scroll Speed: "+str(int(speed))+"[/center]"
	%ScrollSpeed.modulate.a = 1.0
	fade_out(%ScrollSpeed, 0.2)
	
	
func fade_out(label: RichTextLabel, duration: float):
	var tree = get_tree()
	if not is_instance_valid(tree):
		return
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 0.0, duration) 


func Hit(type: String):
	%HitStatus.text = "[center]"+type+"[/center]"
	%HitStatus.modulate.a = 1.0
	fade_out(%HitStatus, 0.2)

	if type == "Miss":
		if combo > 10 and enabled:
			$CanvasLayer/MissSound.play()
		combo = 0
		
	else:
		combo += 1
		score += combo * points_dict[type] / (1 + int(is_dead))
	acc_notes_total += 1
	acc_notes_sum += accuracy_dict[type]

	%Accuracy.text = "[right]" + str(float(acc_notes_sum) / acc_notes_total).pad_decimals(2) + "%" + "[/right]"
	%Combo.text = "[center]"+str(combo)+"[/center]" if combo else ""
	%Score.text = "[right]" + str(score) + "[/right]"
	
func get_notes_sum():
	return acc_notes_sum
