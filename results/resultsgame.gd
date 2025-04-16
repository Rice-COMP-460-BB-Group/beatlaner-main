extends Control

var display_time = 5.0
var buttons_enabled = false
@onready var timer = $CountdownTimer
@onready var progress_bar = $MainContainer/TimerSection/ProgressBar
@onready var timer_value_label = $MainContainer/TimerSection/TimerContainer/TimerValue

@export var win: bool = false
# Called when the node enters the scene tree for the first time.

var new_stat_name = {
	"player_kill_count": "Player Kills",
	"minion_kill_count": "Minion Kills",
	#"total_damage_dealt": 0,
	#"total_damage_received": 0,
	"death_count": "Death Count",
	#"ability_used_count": 0,
	"osu_highest_combo": "Highest Combo",
	#"osu_notes_hit_count": 0,
	#"osu_average_accuracy": "Osu Accuracy", 
	"minion_spawn_count": "Minion Spawn Count",
	#"match_length": 0
	"mana_generated": "Mana Generated"

}

func update_stats_display():
	# Clear the text first
	$MainContainer/HeaderSection/ResultDisplay/ResultBanner/ResultLabel.text = 'VICTORY' if multiplayer.get_unique_id() == MatchStats.get_winner() else 'DEFEAT'
		

	# Get all stats from MatchStats
	var all_stats = MatchStats.get_all_stats()
	print(multiplayer.get_unique_id(), ' all stats', all_stats)
	
	var idx = 1
	# Iterate over each player
	var sorted_keys = all_stats.keys()
	sorted_keys.sort()
	var second_id = sorted_keys[1]
	$MainContainer/ContentContainer/StatsGrid/Player1KDA.text = str(all_stats[1]["player_kill_count"]) + " / " + str(all_stats[1]["death_count"])
	$MainContainer/ContentContainer/StatsGrid/Player1Mana.text = str(all_stats[1]["mana_generated"])
	$MainContainer/ContentContainer/StatsGrid/Player1Minions.text = str(all_stats[1]["minion_kill_count"])
	$MainContainer/ContentContainer/StatsGrid/Player1Combo.text = str(all_stats[1]["osu_highest_combo"])
	$MainContainer/ContentContainer/StatsGrid/Player1Spawned.text = str(all_stats[1]["minion_spawn_count"])
	var p1title = ""
	if all_stats[1]["death_count"] > 10:
		p1title = "Professional Inter"
	if all_stats[1]["death_count"] == 0:
		p1title = "Can't touch this"
	if all_stats[1]["minion_kill_count"] > 100:
		p1title = "The Minion Slayer"
	if all_stats[1]["osu_highest_combo"] > 100:
		p1title = "Missed Life, Not Notes"
	if all_stats[1]["total_damage_dealt"] > 10000:
		p1title = "Actually Bronze in league"
	$MainContainer/ContentContainer/StatsGrid/Player1Info/PlayerDetails/PlayerTitle.text = p1title if p1title else ""

	if len(sorted_keys) > 1:
		$MainContainer/ContentContainer/StatsGrid/Player2KDA.text = str(all_stats[second_id]["player_kill_count"]) + " / " + str(all_stats[second_id]["death_count"])
		$MainContainer/ContentContainer/StatsGrid/Player2Mana.text = str(all_stats[second_id]["mana_generated"])
		$MainContainer/ContentContainer/StatsGrid/Player2Minions.text = str(all_stats[second_id]["minion_kill_count"])
		$MainContainer/ContentContainer/StatsGrid/Player2Combo.text = str(all_stats[second_id]["osu_highest_combo"])
		$MainContainer/ContentContainer/StatsGrid/Player2Spawned.text = str(all_stats[second_id]["minion_spawn_count"])
		
		var p2title = ""
		if all_stats[second_id]["death_count"] > 10:
			p2title = "Professional Inter"
		if all_stats[second_id]["death_count"] == 0:
			p2title = "Can't touch this"
		if all_stats[second_id]["minion_kill_count"] > 100:
			p2title = "The Minion Slayer"
		if all_stats[second_id]["osu_highest_combo"] > 100:
			p2title = "Missed Life, Not Notes"
		if all_stats[second_id]["total_damage_dealt"] > 10000:
			p2title = "Actually Bronze in league"
		if p2title:
			$MainContainer/ContentContainer/StatsGrid/Player2Info/PlayerDetails/PlayerTitle.text = p2title if p2title else ""
	var total_seconds = all_stats[1]["match_length"] / 1000  # Convert ms to seconds
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	$MainContainer/MatchDetailsSection/MatchStats/MatchTimeValue.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _ready():
	if len(GameManager.Players) <= 1:
		%Player2Info.hide()
		%Player2KDA.hide()
		%Player2Mana.hide()
		%Player2Minions.hide()
		%Player2Combo.hide()
		%Player2Spawned.hide()
	call_deferred("update_stats_display")

	if !has_node("CountdownTimer"):
		timer = Timer.new()
		timer.name = "CountdownTimer"
		add_child(timer)
	
	timer.wait_time = 5.0
	timer.one_shot = true
	
	timer.timeout.connect(_on_timer_timeout)
	
	progress_bar.value = 100
	timer_value_label.text = str(int(display_time))
	timer.start()


func _process(delta: float) -> void:
	timer_value_label.text = str(int(ceil(timer.time_left)))
	progress_bar.value = timer.time_left / timer.wait_time * 100

func _on_timer_timeout():
	enable_buttons()
	$MainContainer/TimerSection/TimerContainer/TimerValue.hide()

func enable_buttons():
	if buttons_enabled:
		return
		
	buttons_enabled = true
	$MainContainer/ButtonsContainer/MainMenuButton.disabled = false
	$MainContainer/ButtonsContainer/ExitGameButton.disabled = false
	
	$MainContainer/ButtonsContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$MainContainer/ButtonsContainer/ExitGameButton.pressed.connect(_on_exit_game_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://title/titlescreen.tscn")

func _on_exit_game_pressed():
	get_tree().quit()
