class_name SelectableComponent

extends Area2D

@export var is_selected : bool = false
@export var size_offset : Vector2 = Vector2(10, 10)
var select_panel : Panel
var size : Vector2
var rect_size : Rect2

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
	if is_selected: return
	is_selected = true
	selected.emit()
	select_panel.show()
	pass

func deselect():
	if not is_selected: return
	is_selected = false
	deselected.emit()
	select_panel.hide()
	pass

func _unhandled_input(event : InputEvent):
	if event.is_action("left_click"):
		if event.is_pressed():
			deselect()
	if event.is_action("right_click") and Rect2(global_position - size * 0.5, size).has_point(event.global_position):
		if event.is_pressed():
			action_target.emit()
	pass

func _on_input_event(viewport, event : InputEvent, shape_idx):
	if event.is_action("left_click"):
		if event.is_pressed():
			select()
	pass # Replace with function body.
