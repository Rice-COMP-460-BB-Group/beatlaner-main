extends Control

var type = ""
var score = 0
var acc_notes_sum = 0
var acc_notes_total = 0
var combo = 0

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.Hit.connect(Hit)


func Hit(type: String):
	%HitStatus.text = type
	if type == "Miss":
		combo = 0
	else:
		combo += 1
		score += combo * points_dict[type]
	acc_notes_total += 1
	acc_notes_sum += accuracy_dict[type]
	%Accuracy.text = str(acc_notes_sum / acc_notes_total)
	%Combo.text = str(combo)
	%Score.text = str(score)
