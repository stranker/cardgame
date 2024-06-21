class_name Building

extends StaticBody2D

@export var is_enemy : bool = false
@onready var health_component : HealthComponent = $HealthComponent
@onready var select_component : SelectableComponent = $SelectableComponent
@export var health : float = 10
@export var max_health : float = 10

signal destroy(building)

func _ready():
	health_component.init(health,max_health)
	health_component.dead.connect(on_health_dead)
	select_component.selected.connect(on_building_selected)
	select_component.deselected.connect(on_building_deselected)
	pass

func take_damage(amount : float):
	health_component.take_damage(amount)
	pass

func do_action(data : SelectionManager.PointData, multiple_selection : bool):
	pass

func on_health_dead():
	destroy.emit(self)
	queue_free()
	pass

func on_building_selected():
	health_component.object_select_update(true)
	pass # Replace with function body.

func on_building_deselected():
	health_component.object_select_update(false)
	pass # Replace with function body.
