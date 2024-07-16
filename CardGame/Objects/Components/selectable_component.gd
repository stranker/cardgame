class_name SelectableComponent

extends Area2D

@export var is_selected : bool = false
@export var select_target : AnimatedSprite2D
var is_mouse_inside : bool = false

signal selected()
signal deselected()
signal action_target()

func _ready():
	selected.connect(SelectionManager.add_selected_object.bind(get_parent()))
	action_target.connect(SelectionManager.on_action_targeted.bind(get_parent()))
	select_target.hide()
	pass

func select():
	is_selected = true
	selected.emit()
	select_target.show()
	pass

func deselect():
	is_selected = false
	select_target.hide()
	deselected.emit()
	pass

func _input(event : InputEvent):
	if event.is_action("right_click") and is_mouse_inside:
		if event.is_pressed():
			get_viewport().set_input_as_handled()
			action_target.emit()

func _on_input_event(viewport, event : InputEvent, shape_idx):
	if event.is_action("left_click") and is_mouse_inside:
		if event.is_pressed():
			select()
	pass # Replace with function body.


func _on_mouse_entered():
	is_mouse_inside = true
	pass # Replace with function body.


func _on_mouse_exited():
	is_mouse_inside = false
	pass # Replace with function body.
