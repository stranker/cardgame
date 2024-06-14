class_name NavigationComponent

extends Node2D

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
@export var min_distance_attack : float = 20.0
var speed : float = 0
var target : Node2D

signal velocity_computed(vel)
signal position_reached()
signal target_reached(target)

func init(new_speed : float):
	speed = new_speed
	navigation_agent.max_speed = speed
	pass

func target_object(obj : Node2D):
	print_debug("target_object")
	target = obj
	move_to_position(obj.global_position)
	pass

func force_move_to_position(pos : Vector2):
	target = null
	move_to_position(pos)
	pass

func move_to_position(pos : Vector2):
	navigation_agent.target_position = pos
	set_physics_process(true)
	pass

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
	if target:
		move_to_position(target.global_position)
		if global_position.distance_to(target.global_position) < min_distance_attack:
			navigation_agent.target_position = get_parent().global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	var steering = new_velocity - navigation_agent.velocity
	var vel = navigation_agent.velocity
	vel += steering
	_on_velocity_computed(vel)
	pass

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	_on_velocity_computed(safe_velocity)
	pass # Replace with function body.

func _on_velocity_computed(vel : Vector2):
	velocity_computed.emit(vel)
	pass

func _on_navigation_agent_2d_target_reached():
	if target:
		target_reached.emit(target)
		print_debug("Target Reached")
	else:
		position_reached.emit()
	set_physics_process(false)
	pass # Replace with function body.
