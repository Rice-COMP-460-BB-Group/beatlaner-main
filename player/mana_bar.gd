extends VBoxContainer

@export var mana = 0
@export var max_mana = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var each_max_mana = max_mana / max(1, $ManaBar.get_children().size())
	for child in $ManaBar.get_children():
		if child is TextureProgressBar:
			child.max_value = each_max_mana
	
	set_manabar(mana)

func set_manabar(mana: int) -> void:
	mana = min(mana, max_mana)
	var current_mana = self.mana
	var text_tween = create_tween()
	#text_tween.tween_method(func(v): $ManaText.text = "Mana\n" + str(int(v)) + " / " + str(max_mana),
		#current_mana, mana, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	self.mana = mana
	var draft_mana = mana
	for child in $ManaBar.get_children():
		if child is TextureProgressBar:
			var target_value = min(draft_mana, child.max_value)
			var tween = create_tween()
			tween.tween_property(child, "value", target_value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			draft_mana = max(0, draft_mana - child.max_value)

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
