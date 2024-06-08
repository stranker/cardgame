class_name ConstructComponent

extends Area2D

var objects_inside : Array = []

func is_position_available():
	return objects_inside.is_empty()

func _on_area_entered(area):
	objects_inside.append(area.get_parent())
	pass

func _on_area_exited(area):
	objects_inside.erase(area.get_parent())
	pass # Replace with function body.
