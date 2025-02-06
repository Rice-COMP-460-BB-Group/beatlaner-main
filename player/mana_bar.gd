extends HFlowContainer

@export var mana = 0
@export var max_mana = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var each_max_mana = max_mana / self.get_children().size()
	for child in self.get_children():
		if child is TextureProgressBar:
			child.max_value = each_max_mana
	
	set_manabar(mana)

func set_manabar(mana: int) -> void:
	self.mana = mana
	var draft_mana = mana
	for child in self.get_children():
		if child is TextureProgressBar:
			if draft_mana > child.max_value:
				child.value = child.max_value
				draft_mana -= child.max_value
			else:
				child.value = draft_mana
				draft_mana = 0

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
