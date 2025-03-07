extends VBoxContainer

@export var mana = 0
@export var max_mana = 300.0
var glow_tweens: Dictionary = {} 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var each_max_mana = max_mana / max(1, $ManaBar.get_children().size())
	for child in $ManaBar.get_children():
		if child is TextureProgressBar:
			child.max_value = each_max_mana
			child.tint_progress = Color(1.5, 1.5, 1.5, 1)
	
	set_manabar(mana)
func custom_sort(a, b):
	# Convert the name to a String
	var a_name = str(a.name)
	var b_name =str(b.name)

	var a_num = int(a_name.substr(a_name.length() - 1, 1)) 
	var b_num = int(b_name.substr(b_name.length() - 1, 1)) 

	return a_num > b_num 
	
func custom_sort_reverse(a, b):
	# Convert the name to a String
	var a_name = str(a.name)
	var b_name =str(b.name)

	var a_num = int(a_name.substr(a_name.length() - 1, 1)) 
	var b_num = int(b_name.substr(b_name.length() - 1, 1)) 

	return a_num < b_num 


func set_manabar(mana: int) -> void:
	mana = min(mana, max_mana)
	var current_mana = self.mana
	var is_increasing = self.mana <= mana
	print('is increasing', is_increasing)
	var text_tween = create_tween()
	text_tween.tween_method(func(v): $ManaText.text = "Mana\n" + str(int(v)) + " / " + str(max_mana),
		current_mana, mana, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	self.mana = mana
	var draft_mana = mana
	var children = $ManaBar.get_children()
	if is_increasing:
		children.sort_custom(custom_sort_reverse)
	else:
		children.sort_custom(custom_sort)
	for child in children:
		if is_increasing:
			print('bar name increasing', child.name)
		else:
			print('bar name decreasing', child.name)
	for child in children:
		if child is TextureProgressBar:
			var target_value = min(draft_mana, child.max_value)
			var tween = create_tween()
			tween.tween_property(child, "value", target_value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			await tween.finished
			draft_mana = max(0, draft_mana - child.max_value)
			
			if target_value >= child.max_value:
				start_glow_effect(child)
			else:
				stop_glow_effect(child)

func start_glow_effect(progress_bar: TextureProgressBar) -> void:
	if progress_bar in glow_tweens and glow_tweens[progress_bar]:
		glow_tweens[progress_bar].kill()
	
	progress_bar.modulate = Color(1, 1, 1, 1)
	var new_tween = create_tween()
	new_tween.set_loops()
	
	new_tween.tween_property(progress_bar, "modulate",
		Color(2, 2, 2, 1), 0.5)
	new_tween.tween_property(progress_bar, "modulate",
		Color(1, 1, 1, 1), 0.5)
		
	glow_tweens[progress_bar] = new_tween

func stop_glow_effect(progress_bar: TextureProgressBar) -> void:
	if progress_bar in glow_tweens and glow_tweens[progress_bar]:
		glow_tweens[progress_bar].kill()
		glow_tweens.erase(progress_bar)
	progress_bar.modulate = Color(1, 1, 1, 1)

func increase_mana(amount: int) -> void:
	self.mana += amount
	if self.mana > max_mana:
		self.mana = max_mana
	set_manabar(self.mana)

func decrease_mana(amount: int) -> void:
	self.mana -= amount
	if self.mana < 0:
		self.mana = 0
	set_manabar(self.mana)
