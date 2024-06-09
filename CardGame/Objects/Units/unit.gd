class_name Unit

extends CharacterBody2D

@onready var navigation : NavigationComponent = $NavigationComponent

func _ready():
	navigation.init(200)
	navigation.velocity_computed.connect(on_velocity_computed)

func do_action(data : SelectionManager.PointData, multiple_selection : bool):
	#if data.object:
	move_to_position(data.position)
	pass

func move_to_position(pos : Vector2):
	navigation.move_to_target(pos)
	pass

func on_velocity_computed(vel : Vector2):
	velocity = vel
	move_and_slide()
	pass
