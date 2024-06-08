class_name ConstructComponent

extends Area2D

enum ConstructState { AVAILABLE, UNAVAILABLE }
var construct_state = ConstructState.AVAILABLE
var objects_inside : Array = []

signal construct_available()
signal construct_unavailable()

func is_position_available():
	return objects_inside.is_empty()

func _on_area_entered(area):
	objects_inside.append(area.get_parent())
	construct_state = ConstructState.UNAVAILABLE
	construct_unavailable.emit()
	pass

func _on_area_exited(area):
	objects_inside.erase(area.get_parent())
	if objects_inside.is_empty():
		construct_state = ConstructState.AVAILABLE
		construct_available.emit()
	pass # Replace with function body.

func construct():
	monitoring = false
	pass
