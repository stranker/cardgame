extends Node

signal construct_success
signal construct_failed

func on_create_card_object(card : Card):
	var obj : Node2D = card.get_object_scene().instantiate()
	get_tree().root.add_child(obj)
	obj.global_position = card.global_position
	pass
