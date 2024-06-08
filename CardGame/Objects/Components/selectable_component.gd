class_name SelectableComponent

extends Area2D

@export var is_selected : bool = false
@export var size_offset : Vector2 = Vector2(10, 10)
var select_panel : Panel
var size : Vector2
var rect_size : Rect2
var is_mouse_inside : bool = false

signal selected()
signal deselected()
signal action_target()

func _ready():
	size = get_child(0).shape.size + size_offset
	selected.connect(SelectionManager.add_selected_object.bind(get_parent()))
	deselected.connect(SelectionManager.remove_selected_object.bind(get_parent()))
	action_target.connect(SelectionManager.on_action_target.bind(get_parent()))
	select_panel = get_child(1)
	select_panel.hide()
	pass

func select():
	is_selected = true
	selected.emit()
	select_panel.show()
	pass

func deselect():
	is_selected = false
	deselected.emit()
	select_panel.hide()
	pass

func _unhandled_input(event : InputEvent):
	if event.is_action("right_click") and is_mouse_inside:
		if event.is_pressed():
			action_target.emit()
	pass

func _on_input_event(viewport, event : InputEvent, shape_idx):
	if event.is_action("left_click") and is_mouse_inside:
		print_debug("_on_input_event")
		if event.is_pressed():
			select()
	pass # Replace with function body.


func _on_mouse_entered():
	is_mouse_inside = true
	pass # Replace with function body.


func _on_mouse_exited():
	is_mouse_inside = false
	pass # Replace with function body.
