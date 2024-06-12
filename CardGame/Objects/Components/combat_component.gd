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

func attack_target(target : Node2D):
	if not can_attack: return
	current_target = target
	can_attack = false
	attack_timer.start()
	attack.emit(target)
	pass

func _on_attack_timer_timeout():
	can_attack = true
	end_attack.emit()
	if global_position.distance_to(current_target.global_position) < min_attack_distance:
		attack_target(current_target)
	else:
		target_out_of_range.emit(current_target)
	pass
