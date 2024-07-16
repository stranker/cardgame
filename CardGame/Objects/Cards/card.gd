extends Node2D

class_name Card

@export var card_data : CardData

@export var background : Sprite2D
@export var anim : AnimationPlayer
var initial_position : Vector2
var mid_position : Vector2
var rotation_factor : float = 0
var is_highlighted : bool = false

enum MovementState { IDLE, DRAG }
enum PickState { DISABLED, ENABLED }

@export var movement_state : MovementState = MovementState.IDLE
@export var pick_state : PickState = PickState.ENABLED
@export var interact_area : Area2D
@export var card_image : TextureRect
@export var card_name : Label
@export var card_description : Label

signal card_picked(card)
signal card_dropped(card)
signal card_try_highlighted(card)
signal card_unhighlighted(card)
signal card_highligthed(card)

func _ready():
	mid_position = get_parent().global_position
	card_picked.connect(SelectionManager.on_card_selected)
	card_dropped.connect(SelectionManager.on_card_deselected)
	card_try_highlighted.connect(SelectionManager.on_card_try_highligthed)
	card_unhighlighted.connect(SelectionManager.on_card_unhighligthed)
	card_picked.connect(ConstructManager.on_card_picked)
	card_dropped.connect(ConstructManager.on_card_dropped)
	pass

func set_data(new_card_data : CardData):
	card_data = new_card_data
	card_image.texture = card_data.card_image
	card_name.text = card_data.card_name
	card_description.text = card_data.card_description
	pass

func get_size_x():
	return background.texture.get_size().x

func set_new_position(pos : Vector2):
	initial_position = pos
	global_position = initial_position
	var distance_to_mid = global_position.distance_to(mid_position)
	rotation_factor = distance_to_mid / get_size_x()
	if global_position.x < mid_position.x:
		rotation_factor *= -1
	rotation_degrees = rotation_factor * 4
	global_position.y = initial_position.y + 16 * abs(rotation_factor)
	initial_position = global_position
	pass

func get_object_scene():
	return card_data.card_object_scene

func disabled():
	pick_state = PickState.DISABLED
	interact_area.monitoring = false
	anim.play("Disabled")
	pass

func enable():
	pick_state = PickState.ENABLED
	interact_area.monitoring = true
	anim.play_backwards("Disabled")
	pass

func reset():
	var tween = create_tween()
	tween.parallel()
	tween.parallel().tween_property(self, "global_position", initial_position, 0.2).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation_degrees", rotation_factor * 4, 0.2).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(background, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN)
	tween.play()
	pick_state = PickState.ENABLED
	pass


func _on_interact_mouse_entered():
	if pick_state == PickState.DISABLED: return
	card_try_highlighted.emit(self)
	pass # Replace with function body.


func _on_interact_mouse_exited():
	if pick_state == PickState.DISABLED: return
	card_unhighlighted.emit(self)
	pass # Replace with function body.

func unhighlight():
	if not is_highlighted: return
	is_highlighted = false
	anim.play_backwards("Highlighted")
	pass

func highlight():
	if is_highlighted: return
	is_highlighted = true
	card_highligthed.emit(self)
	anim.play("Highlighted")
	pass

func _on_interact_input_event(viewport, event, shape_idx):
	if pick_state == PickState.DISABLED or not can_pick_card(): return
	if event.is_action("left_click"):
		if event.pressed:
			movement_state = MovementState.DRAG
			var tween = create_tween()
			tween.parallel().tween_property(self, "rotation_degrees", 0, 0.3).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(background, "modulate:a", 0, 0.3).set_ease(Tween.EASE_IN)
			tween.play()
			card_picked.emit(self)
		else:
			if movement_state == MovementState.DRAG:
				movement_state = MovementState.IDLE
				card_dropped.emit(self)
	if event is InputEventMouseMotion and movement_state == MovementState.DRAG:
		global_position = get_global_mouse_position()
	pass # Replace with function body.

func can_pick_card():
	return card_data.card_cost <= GameManager.mana
