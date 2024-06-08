extends Node2D

signal construct_success(card)
signal construct_failed(card)

var current_card_object : Node2D

enum ConstructPhase { IDLE, CONSTRUCT }
var construct_phase : ConstructPhase = ConstructPhase.IDLE

func _process(delta):
	if not current_card_object: return
	current_card_object.global_position = get_global_mouse_position()
	pass

func create_card_object(card : Card):
	construct_phase = ConstructPhase.CONSTRUCT
	current_card_object = card.get_object_scene().instantiate()
	get_tree().root.get_node("TestScene/Map").add_child(current_card_object)
	current_card_object.global_position = card.global_position
	set_process(true)
	pass

func on_card_picked(card : Card):
	create_card_object(card)
	pass

func on_card_dropped(card : Card):
	if current_card_object.get_node("ConstructComponent").is_position_available():
		set_process(false)
		construct_phase = ConstructPhase.IDLE
		construct_success.emit(card)
		current_card_object.get_node("ConstructComponent").construct()
	else:
		current_card_object.queue_free()
		current_card_object = null
		construct_failed.emit(card)
	pass
