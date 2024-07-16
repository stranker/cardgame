extends CanvasLayer

@export var mana_label : Label

func _ready():
	_update_mana_text(GameManager.mana)
	GameManager.mana_update.connect(on_mana_update)
	pass

func _update_mana_text(value : float):
	mana_label.text = "Mana: " + str(value)
	pass

func on_mana_update(value : float):
	_update_mana_text(value)
	pass
