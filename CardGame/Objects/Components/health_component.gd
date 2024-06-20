class_name HealthComponent

extends Node2D

@export var health : float
@export var max_health : float
@export var health_bar : ProgressBar
@export var destructible : bool = true

signal health_update(health, max_health)
signal dead()

func _ready():
	health_bar.hide()
	pass

func init(_health, _max_health):
	health = _health
	max_health = _max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = max_health
	pass

func heal(amount : float):
	health += amount
	_clamp_health_and_update()
	pass

func take_damage(amount : float):
	if health <= 0 or not destructible: return
	health -= amount
	_clamp_health_and_update()
	pass

func _clamp_health_and_update():
	health = clamp(health, 0, max_health)
	health_bar.value = health
	if health > 0:
		health_update.emit(health, max_health)
	else:
		dead.emit()
	pass

func object_select_update(is_selected : bool):
	health_bar.visible = is_selected
	pass
