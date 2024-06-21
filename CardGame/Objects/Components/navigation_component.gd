class_name NavigationComponent

extends Node2D

enum State { POSITION, TARGET }
@export var state : State = State.POSITION 

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
@export var min_distance_attack : float = 20.0
@export var ray_cast_pivot : Node2D
@export var front_ray_cast : RayCast2D

var speed : float = 0
var target : Node2D
var target_position : Vector2

var debug_direction : Vector2

signal velocity_computed(vel)
signal position_reached()
signal target_reached(target)

func init(new_speed : float):
	speed = new_speed
	navigation_agent.max_speed = speed
	for ray_cast in ray_cast_pivot.get_children():
		ray_cast.add_exception(get_parent())
	pass

func target_object(obj : Node2D):
	#print_debug("target_object")
	target = obj
	state = State.TARGET
	if not target.destroy.is_connected(on_target_destroyed):
		target.destroy.connect(on_target_destroyed)
	move_to_position(obj.global_position)
	pass

func force_move_to_position(pos : Vector2):
	target = null
	state = State.POSITION
	move_to_position(pos)
	pass

func move_to_position(pos : Vector2):
	$Timer.start()
	set_enable_raycasts(true)
	navigation_agent.target_position = pos
	target_position = pos
	set_physics_process(true)
	pass

func set_enable(value : bool):
	navigation_agent.avoidance_enabled = value
	set_physics_process(value)
	pass

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
	match state:
		State.POSITION:
			_process_position(delta)
		State.TARGET:
			_process_target(delta)
	pass

func _process_position(delta : float):
	_process_movement(delta)
	pass

func _draw():
	draw_line(Vector2.ZERO, debug_direction * 100, Color.GREEN, 3)

func _process_target(delta : float):
	if not is_instance_valid(target): return
	move_to_position(target.global_position)
	_process_movement(delta)
	pass

func _process_movement(delta : float):
	var direction = global_position.direction_to(navigation_agent.get_next_path_position())
	ray_cast_pivot.rotation = atan2(direction.y, direction.x)
	if front_ray_cast.is_colliding():
		if front_ray_cast.get_collider().is_enemy and is_instance_valid(target):
			front_ray_cast.enabled = false
		$Timer.stop()
		for ray_cast in ray_cast_pivot.get_children():
			if not ray_cast.is_colliding():
				direction = global_position.direction_to(ray_cast.to_global(ray_cast.target_position))
				break
		debug_direction = direction
		queue_redraw()
	var new_velocity: Vector2 = direction * speed
	var steering = new_velocity - navigation_agent.velocity
	var vel = navigation_agent.velocity
	vel += steering
	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = vel
	else:
		_on_velocity_computed(vel)
	pass

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	_on_velocity_computed(safe_velocity)
	pass # Replace with function body.

func _on_velocity_computed(vel : Vector2):
	velocity_computed.emit(vel)
	pass

func _on_navigation_agent_2d_target_reached():
	if is_instance_valid(target):
		#print_debug("Target Reached:", target.name)
		target_reached.emit(target)
	else:
		position_reached.emit()
	$Timer.stop()
	set_enable_raycasts(false)
	pass # Replace with function body.

func set_enable_raycasts(value : bool):
	for ray_cast in ray_cast_pivot.get_children():
		ray_cast.enabled = value
	pass

func on_target_destroyed(target):
	pass

func _on_timer_timeout():
	_recalculate_path()
	pass # Replace with function body.

func _recalculate_path():
	if is_instance_valid(target):
		navigation_agent.target_position = target.global_position
	else:
		navigation_agent.target_position = target_position
	pass
