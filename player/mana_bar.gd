extends Control

@export var mana = 0
@export var max_mana = 300.0
var glow_tweens: Dictionary = {}
var master_glow_tween = null
var animation_in_progress = false
var pending_mana_update = null
var current_tween = null
var filled_bars = []  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var each_max_mana = max_mana / max(1, $ManaBar.get_children().size())
	for child in $ManaBar.get_children():
		if child is TextureProgressBar:
			child.max_value = each_max_mana
			child.tint_progress = Color(1.5, 1.5, 1.5, 1)
	
	set_manabar(mana)
	setup_master_glow()

func set_manabar(target_mana: int) -> void:
	target_mana = min(target_mana, max_mana)
	
	# If animation already running, store the pending update
	if animation_in_progress:
		pending_mana_update = target_mana
		return
	
	animation_in_progress = true
	var current_mana = self.mana
	self.mana = target_mana
	
	# Update text with tween
	var text_tween = create_tween()
	text_tween.tween_method(func(v): $ManaText.text = "Mana\n" + str(int(v)) + " / " + str(max_mana),
		current_mana, target_mana, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	animate_bars_sequentially(current_mana, target_mana)

func animate_bars_sequentially(from_mana: int, to_mana: int) -> void:
	if current_tween != null:
		current_tween.kill()
	
	current_tween = create_tween()
	
	var progress_bars = $ManaBar.get_children()
	progress_bars.sort_custom(func(a, b): return a.get_index() < b.get_index())
	
	var is_increasing = to_mana > from_mana
	
	var bar_values = []
	var remaining_mana = to_mana
	
	for bar in progress_bars:
		if bar is TextureProgressBar:
			var value = min(remaining_mana, bar.max_value)
			bar_values.append(value)
			remaining_mana = max(0, remaining_mana - bar.max_value)
	
	filled_bars.clear()
	
	var animation_bars = progress_bars.duplicate()
	if not is_increasing:
		animation_bars.reverse() 
	
	for i in range(animation_bars.size()):
		var bar = animation_bars[i]
		if bar is TextureProgressBar:
			var original_index = progress_bars.find(bar)
			var target_value = bar_values[original_index]
			var current_value = bar.value
			
			if current_value != target_value:
				current_tween.tween_property(bar, "value", target_value, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				current_tween.tween_callback(func(): update_glow_status(bar, target_value))
				
				if i < animation_bars.size() - 1:
					current_tween.tween_interval(0.1)
	
	current_tween.tween_callback(func():
		animation_in_progress = false
		if pending_mana_update != null:
			var next_target = pending_mana_update
			pending_mana_update = null
			set_manabar(next_target)
	)

func update_glow_status(progress_bar: TextureProgressBar, value: float) -> void:
	if value >= progress_bar.max_value:
		if not filled_bars.has(progress_bar):
			filled_bars.append(progress_bar)
	else:
		if filled_bars.has(progress_bar):
			filled_bars.erase(progress_bar)

func setup_master_glow() -> void:
	if master_glow_tween:
		master_glow_tween.kill()
	
	master_glow_tween = create_tween()
	master_glow_tween.set_loops()
	
	master_glow_tween.tween_property(self, "glow_intensity", 2.0, 0.5)
	master_glow_tween.tween_property(self, "glow_intensity", 1.0, 0.5)
	
	set_process(true)

var glow_intensity: float = 1.0:
	set(value):
		glow_intensity = value
		for bar in filled_bars:
			if is_instance_valid(bar):
				bar.modulate = Color(value, value, value, 1)

func _process(_delta) -> void:
	for bar in $ManaBar.get_children():
		if bar is TextureProgressBar:
			if filled_bars.has(bar):
				bar.modulate = Color(glow_intensity, glow_intensity, glow_intensity, 1)
			else:
				bar.modulate = Color(1, 1, 1, 1)

func increase_mana(amount: int) -> void:
	set_manabar(self.mana + amount)

func decrease_mana(amount: int) -> void:
	set_manabar(max(0, self.mana - amount))
