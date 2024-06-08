extends Node2D

signal construct_success
signal construct_failed

var current_card_object : Node2D

enum ConstructPhase { IDLE, START, FINISH }
var construct_phase : ConstructPhase = ConstructPhase.IDLE

func _process(delta):
	if not current_card_object: return
	current_card_object.global_position = get_global_mouse_position()
	pass

func create_card_object(card : Card):
	construct_phase = ConstructPhase.START
	current_card_object = card.get_object_scene().instantiate()
	get_tree().root.add_child(current_card_object)
	current_card_object.global_position = card.global_position
	set_process(true)
	pass

func on_card_picked(card : Card):
	create_card_object(card)
	pass

func on_card_dropped(card : Card):
	construct_phase = ConstructPhase.FINISH
	set_process(false)
	pass
