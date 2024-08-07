extends Node2D

var selection_area : Area2D
var selection_collision : CollisionShape2D
var selection_shape : RectangleShape2D
var selected_objects : Array

var start_pos : Vector2
var end_pos : Vector2
var selection_rect : Rect2
var is_multiple_selection : bool = false

enum InteractionState { CARD, OBJECT }
enum SelectionState { IDLE, SELECT, END_SELECT }

var interaction_state : InteractionState = InteractionState.OBJECT
var selection_state : SelectionState = SelectionState.IDLE

var cards_highligthed_queue : Array[Card]

@onready var selection_panel_scene : = preload("res://Objects/Misc/selection.tscn")
var selection_panel : Panel

class PointData:
	var position : Vector2
	var object : Node2D
	
	func _to_string():
		return "PointData:(" + str(position) + " - " + str(object) + ")"

func _ready():
	selection_area_setup.call_deferred()
	selection_panel = selection_panel_scene.instantiate()
	add_child(selection_panel)
	selection_panel.hide()
	pass

func selection_area_setup():
	await get_tree().process_frame
	_add_selection_area()
	pass

func _add_selection_area():
	selection_area = Area2D.new()
	selection_area.set_collision_layer_value(1, false)
	selection_area.set_collision_mask_value(2, true)
	selection_area.set_collision_mask_value(3, true)
	selection_collision = CollisionShape2D.new()
	add_child(selection_area)
	selection_area.add_child(selection_collision)
	selection_shape = RectangleShape2D.new()
	selection_collision.shape = selection_shape
	selection_area.body_entered.connect(on_select_object)
	selection_area.body_exited.connect(on_deselect_object)
	pass

func add_selected_object(obj : Node2D):
	if selected_objects.has(obj): return
	selected_objects.append(obj)
	is_multiple_selection = selected_objects.size() > 1
	pass

func remove_selected_object(obj : Node2D):
	if not selected_objects.has(obj): return
	selected_objects.erase(obj)
	is_multiple_selection = selected_objects.size() > 1
	pass

func _unhandled_input(event : InputEvent):
	if interaction_state == InteractionState.CARD or not cards_highligthed_queue.is_empty(): return
	if event.is_action("left_click"):
		if event.is_pressed():
			_unselect_all()
			_start_selection_area(event.global_position)
		else:
			_end_selection_area(event.global_position)
	if event is InputEventMouseMotion and selection_state == SelectionState.SELECT:
		_process_selection_area(event.global_position)
	pass

func _draw():
	if interaction_state == InteractionState.CARD: return
	if selection_shape and selection_state == SelectionState.SELECT:
		draw_rect(Rect2(selection_area.global_position - selection_shape.get_rect().size * 0.5, selection_shape.get_rect().size), Color.BLUE, false, 2)
		draw_circle(selection_area.global_position, 5, Color.YELLOW)
		draw_circle(start_pos, 3, Color.BLACK)
		draw_circle(end_pos, 3, Color.PURPLE)
	pass

func _start_selection_area(pos : Vector2):
	if interaction_state == InteractionState.CARD: return
	_reset_selection_area()
	selection_state = SelectionState.SELECT
	start_pos = get_global_mouse_position()
	selection_area.global_position = pos
	selection_panel.show()
	selection_panel.global_position = pos
	pass

func _process_selection_area(pos : Vector2):
	if interaction_state == InteractionState.CARD: return
	selection_area.monitoring = true
	var rect_start_pos : Vector2
	var rect_end_pos : Vector2
	end_pos = get_global_mouse_position()
	rect_end_pos.x = abs(end_pos.x - start_pos.x)
	rect_end_pos.y = abs(end_pos.y - start_pos.y)
	selection_rect = Rect2(rect_start_pos, rect_end_pos)
	if start_pos.y < end_pos.y:
		selection_area.global_position = (start_pos + end_pos) * 0.5
	elif start_pos.y > end_pos.y:
		selection_area.global_position = start_pos + (end_pos - start_pos) * 0.5
	selection_shape.size = selection_rect.size
	selection_panel.size = selection_rect.size
	selection_panel.global_position = selection_area.global_position - selection_panel.size * 0.5
	#queue_redraw()
	pass

func _end_selection_area(pos : Vector2):
	if interaction_state == InteractionState.CARD: return
	selection_state = SelectionState.END_SELECT
	_reset_selection_area()
	#queue_redraw()
	pass

func on_card_selected(card : Card):
	interaction_state = InteractionState.CARD
	selection_state = SelectionState.IDLE
	if cards_highligthed_queue.has(card):
		cards_highligthed_queue.erase(card)
	_reset_selection_area()
	#queue_redraw()
	pass

func _reset_selection_area():
	selection_area.monitoring = false
	end_pos = Vector2.ZERO
	start_pos = Vector2.ZERO
	selection_rect = Rect2()
	selection_shape.size = selection_rect.size
	selection_area.global_position = Vector2.ONE * -9999
	selection_panel.size = Vector2.ZERO
	selection_panel.hide()
	pass

func on_card_deselected(_card : Card):
	interaction_state = InteractionState.OBJECT
	selection_state = SelectionState.IDLE
	queue_redraw()
	pass

func on_card_try_highligthed(card : Card):
	if cards_highligthed_queue.has(card): return
	if card.is_queued_for_deletion(): return
	if not is_instance_valid(card): return
	cards_highligthed_queue.append(card)
	if cards_highligthed_queue.size() == 1:
		card.highlight()
	pass

func on_card_unhighligthed(card : Card):
	if not cards_highligthed_queue.has(card): return
	card.unhighlight()
	cards_highligthed_queue.erase(card)
	if cards_highligthed_queue.is_empty(): return
	if is_instance_valid(cards_highligthed_queue.front()):
		cards_highligthed_queue.front().highlight()
	pass

func on_select_object(body : PhysicsBody2D):
	if selection_state == SelectionState.END_SELECT: return
	body.get_node("SelectableComponent").select()
	add_selected_object(body)
	pass

func on_deselect_object(body : PhysicsBody2D):
	if selection_state == SelectionState.END_SELECT: return
	body.get_node("SelectableComponent").deselect()
	remove_selected_object(body)
	pass

func _unselect_all():
	for obj in selected_objects:
		obj.get_node("SelectableComponent").deselect()
	selected_objects.clear()
	pass

func on_action_targeted(obj : Node2D):
	if selected_objects.is_empty(): return
	var point_data : PointData = PointData.new()
	point_data.position = obj.global_position
	point_data.object = obj
	_process_point_data_on_objects(point_data)
	pass

func _process_selected_objects():
	if selected_objects.is_empty(): return
	var point_data : PointData = PointData.new()
	point_data.position = get_global_mouse_position()
	_process_point_data_on_objects(point_data)
	pass

func _process_point_data_on_objects(data : PointData):
	#print_debug("_process_point_data_on_objects")
	var rand_radius = selected_objects.size() * 10
	var angles_degrees = 360.0 / selected_objects.size()
	var accum_degrees = 0
	for object in selected_objects:
		var new_data : PointData = PointData.new()
		new_data.object = data.object
		var new_pos = data.position + Vector2(cos(deg_to_rad(accum_degrees)), sin(deg_to_rad(accum_degrees))) * rand_radius
		new_data.position = new_pos
		if object.has_method("do_action"):
			object.do_action(new_data)
		accum_degrees += angles_degrees
	pass

func on_map_clicked():
	_process_selected_objects()
	pass

func on_dead_unit(unit):
	remove_selected_object(unit)
	pass
