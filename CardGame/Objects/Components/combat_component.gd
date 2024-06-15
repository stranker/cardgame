class_name CombatComponent

extends Node2D

@export var damage : float = 0
@export var attack_timer : Timer
@export var can_attack : bool = true
@export var min_attack_distance : float = 20
var current_target : PhysicsBody2D

signal attack(target)
signal end_attack()
signal target_out_of_range(target)

func init(_damage : float, _attack_speed : float):
	damage = _damage
	attack_timer.wait_time = _attack_speed
	pass

func _physics_process(delta):
	if not current_target: return
	if global_position.distance_to(current_target.global_position) > min_attack_distance:
		target_out_of_range.emit(current_target)
		set_physics_process(false)
	pass

func attack_target(target : Node2D):
	if not can_attack: return
	set_physics_process(true)
	current_target = target
	can_attack = false
	attack_timer.start()
	if not target.destroy.is_connected(on_target_destroy):
		target.destroy.connect(on_target_destroy)
	var target_health_component : HealthComponent = target.get_node("HealthComponent")
	attack.emit(target)
	target_health_component.take_damage(damage)
	pass

func on_target_destroy(target):
	print_debug("on_target_dead")
	if target == current_target:
		current_target = null
		end_attack.emit()
	pass

func _on_attack_timer_timeout():
	can_attack = true
	if not current_target: return
	if global_position.distance_to(current_target.global_position) < min_attack_distance:
		attack_target(current_target)
	else:
		target_out_of_range.emit(current_target)
	pass

func reset():
	current_target = null
	#end_attack.emit()
	pass
