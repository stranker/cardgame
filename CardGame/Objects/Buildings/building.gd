class_name Building

extends StaticBody2D

@export var is_enemy : bool = false
@onready var health_component : HealthComponent = $HealthComponent
@onready var select_component : SelectableComponent = $SelectableComponent
@onready var visual_component : VisualComponent = $VisualComponent
@onready var construct_component : ConstructComponent = $ConstructComponent
@export var health : float = 10
@export var max_health : float = 10
@export var is_dummy : bool = false


signal destroy(building)

func _ready():
	health_component.init(health,max_health)
	health_component.dead.connect(on_health_dead)
	health_component.hit.connect(on_health_hit)
	select_component.selected.connect(on_building_selected)
	select_component.deselected.connect(on_building_deselected)
	if is_dummy:
		construct_component.construct()
		health_component.destructible = false
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

func on_health_hit():
	visual_component.hit()
	pass
