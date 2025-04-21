extends Control

@export var team: Team = Team.BLUE
enum Team {BLUE, RED}

enum Difficulty {EASY, MEDIUM, HARD}

var easy_votes = 0
var medium_votes = 0
var hard_votes = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer/TextureProgressBar.max_value = $Timer/VoteTime.wait_time
	for button in get_tree().get_nodes_in_group("buttons"):
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(2)
		stylebox.set_border_color(Color.WHITE)
		stylebox.set_bg_color(Color(0.2, 0.2, 0.2))
		stylebox.set_corner_radius_all(8)
		button.add_theme_stylebox_override("normal", stylebox)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Timer/Label.text = str(int(floor($Timer/VoteTime.time_left)))
	$Timer/TextureProgressBar.value = $Timer/VoteTime.time_left

@rpc("call_local", "any_peer")
func new_vote(curTeam: Team, toggled_on: bool, difficulty: Difficulty) -> void:
	var button = get_control_by_difficulty(difficulty).get_node("HBoxContainer")
	if curTeam == Team.BLUE:
		button = button.get_node("VoteBlue")
	else:
		button = button.get_node("VoteRed")
	
	if toggled_on:
		button.visible = true

		if difficulty == Difficulty.EASY:
			easy_votes += 1
		elif difficulty == Difficulty.MEDIUM:
			medium_votes += 1
		elif difficulty == Difficulty.HARD:
			hard_votes += 1
	else:
		button.visible = false

		if difficulty == Difficulty.EASY:
			easy_votes -= 1
		elif difficulty == Difficulty.MEDIUM:
			medium_votes -= 1
		elif difficulty == Difficulty.HARD:
			hard_votes -= 1

func _on_easy_toggled(toggled_on: bool) -> void:
	new_vote.rpc(team, toggled_on, Difficulty.EASY)

func _on_medium_toggled(toggled_on: bool) -> void:
	new_vote.rpc(team, toggled_on, Difficulty.MEDIUM)

func _on_hard_toggled(toggled_on: bool) -> void:
	new_vote.rpc(team, toggled_on, Difficulty.HARD)

func _on_vote_time_timeout() -> void:
	if multiplayer.is_server():
		print("hi from here?")
		var selected_difficulty = determine_difficulty()
		move_to_game.rpc(selected_difficulty)

@rpc("call_local")
func move_to_game(selected_difficulty: Difficulty) -> void:

	for btn in get_tree().get_nodes_in_group("buttons"):
		btn.disabled = true
	var button = get_control_by_difficulty(selected_difficulty).get_node("Button")
	var stylebox = button.get_theme_stylebox("normal").duplicate()
	button.add_theme_stylebox_override("disabled", stylebox)


	var tween = create_tween()
	tween.tween_property(stylebox, "bg_color", Color(1, 1, 1), 0.5)
	tween.tween_property(stylebox, "bg_color", Color(0.2, 0.2, 0.2), 0.5)

	await tween.finished

	var scene = load("res://main/Main.tscn").instantiate()
	scene.current_difficulty = selected_difficulty
	get_tree().get_root().add_child(scene)
	self.hide()

func determine_difficulty() -> Difficulty:
	#print(easy_votes,medium_votes,hard_votes)
	if easy_votes + medium_votes + hard_votes == 0:
		return Difficulty.values()[randi() % 3]

	if easy_votes == 2:
		return Difficulty.EASY
	if medium_votes == 2:
		return Difficulty.MEDIUM
	if hard_votes == 2:
		return Difficulty.HARD

	if easy_votes == 1 and hard_votes == 1:
		return Difficulty.MEDIUM

	if easy_votes == 1 and medium_votes == 1:
		return Difficulty.values()[randi() % 2]

	if medium_votes == 1 and hard_votes == 1:
		return Difficulty.values()[randi() % 2 + 1]

	if easy_votes == 1:
		return Difficulty.EASY
	if medium_votes == 1:
		return Difficulty.MEDIUM
	if hard_votes == 1:
		return Difficulty.HARD
	return Difficulty.EASY

func get_control_by_difficulty(difficulty: Difficulty) -> Control:
	if difficulty == Difficulty.EASY:
		return $DifficultySelector/Easy
	elif difficulty == Difficulty.MEDIUM:
		return $DifficultySelector/Medium
	else:
		return $DifficultySelector/Hard
