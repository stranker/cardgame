class_name CombatComponent

extends Area2D

@export var damage : float = 0
@export var attack_timer : Timer
@export var can_attack : bool = true
@export var min_attack_distance : float = 20
var current_target : PhysicsBody2D

signal attack(target)
signal end_attack()
signal target_out_of_range(target)
signal target_update(target)

func init(_damage : float, _attack_speed : float):
	damage = _damage
	attack_timer.wait_time = _attack_speed
	pass

func set_target(target : PhysicsBody2D):
	print_debug("set_target:", target.name)
	current_target = target
	pass

func _attack():
	if not can_attack: return
	can_attack = false
	attack_timer.start()
	if not current_target.destroy.is_connected(on_target_destroy):
		current_target.destroy.connect(on_target_destroy)
	var target_health_component : HealthComponent = current_target.get_node("HealthComponent")
	attack.emit(current_target)
	target_health_component.take_damage(damage)
	await get_tree().create_timer(0.5)
	end_attack.emit()
	pass

func on_target_destroy(target):
	if target == current_target:
		current_target = null
		target_update.emit(current_target)
		
	pass

func _on_attack_timer_timeout():
	can_attack = true
	if not current_target: return
	_attack()
	pass

func reset():
	current_target = null
	target_update.emit(current_target)
	pass


func _on_body_entered(body):
	if body != current_target: return
	print_debug("ATTACK")
	_attack()
	pass # Replace with function body.


func _on_body_exited(body):
	if body != current_target: return
	target_out_of_range.emit(current_target)
	attack_timer.stop()
	pass # Replace with function body.
