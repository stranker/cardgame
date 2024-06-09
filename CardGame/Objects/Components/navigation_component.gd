class_name NavigationComponent

extends Node2D

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
@onready var timer : Timer = $Timer
@export var min_distance_to_stop : float = 200.0
var speed : float = 0

signal velocity_computed(vel)

func init(new_speed : float):
	speed = new_speed
	navigation_agent.max_speed = speed
	pass

func move_to_target(pos : Vector2):
	navigation_agent.target_position = pos
	timer.stop()
	#set_physics_process(true)
	pass

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)
	if navigation_agent.distance_to_target() < min_distance_to_stop and timer.is_stopped():
		timer.start()
	pass

func _on_timer_timeout():
	navigation_agent.target_position = get_parent().global_position
	#set_physics_process(false)
	pass # Replace with function body.

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	_on_velocity_computed(safe_velocity)
	pass # Replace with function body.

func _on_velocity_computed(vel : Vector2):
	velocity_computed.emit(vel)
	pass
