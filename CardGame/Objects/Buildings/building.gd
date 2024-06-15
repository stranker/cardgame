class_name Building

extends StaticBody2D

@export var is_enemy : bool = false
@onready var health_component : HealthComponent = $HealthComponent
@export var health : float = 10
@export var max_health : float = 10

signal destroy(building)

func _ready():
	health_component.init(health,max_health)
	health_component.dead.connect(on_health_dead)
	pass

func do_action(data : SelectionManager.PointData, multiple_selection : bool):
	pass

func on_health_dead():
	destroy.emit(self)
	queue_free()
	pass
