class_name Unit

extends CharacterBody2D

@onready var navigation : NavigationComponent = $NavigationComponent
@export var is_enemy : bool = false

func _ready():
	navigation.init(200)
	navigation.velocity_computed.connect(on_velocity_computed)
	pass

func do_action(data : SelectionManager.PointData, multiple_selection : bool):
	print_debug("do_action", name)
	if data.object:
		target_object(data.object)
	else:
		move_to_position(data.position)
	pass

func move_to_position(pos : Vector2):
	navigation.force_move_to_position(pos)
	pass

func target_object(obj : Node2D):
	navigation.target_object(obj)
	pass

func on_velocity_computed(vel : Vector2):
	velocity = vel
	move_and_slide()
	pass
