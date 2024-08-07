class_name Unit

extends CharacterBody2D

@onready var navigation : NavigationComponent = $NavigationComponent
@onready var combat_component : CombatComponent = $CombatComponent
@onready var health_component : HealthComponent = $HealthComponent
@onready var select_component : SelectableComponent = $SelectableComponent
@onready var visual_component : VisualComponent = $VisualComponent
@onready var construct_component : ConstructComponent = $ConstructComponent
#@onready var merge_component : MergeComponent = $MergeComponent
@export var is_enemy : bool = false
@export var debug_state : Label
@export var debug_target : Label
@export var debug_name : Label
@export var speed : float = 200
@export var damage : float = 1
@export var attack_speed : float = 1
@export var health : float = 10
@export var max_health : float = 10
@export var is_dummy : bool = false

enum State { SELECT, IDLE, MOVE, ATTACK, FOLLOW }
var state : State = State.IDLE

signal state_update(state)
signal destroy(unit)

func _ready():
	destroy.connect(SelectionManager.on_dead_unit)
	navigation.init(speed)
	navigation.velocity_computed.connect(on_velocity_computed)
	navigation.target_reached.connect(on_target_reached)
	navigation.position_reached.connect(on_position_reached)
	combat_component.end_attack.connect(on_combat_end_attack)
	combat_component.attack.connect(on_combat_attack)
	combat_component.target_out_of_range.connect(on_target_out_of_range)
	combat_component.target_update.connect(on_target_update)
	combat_component.init(damage, attack_speed)
	health_component.init(health, max_health)
	health_component.health_update.connect(on_health_update)
	health_component.hit.connect(on_health_hit)
	health_component.dead.connect(on_health_dead)
	select_component.selected.connect(on_unit_selected)
	select_component.deselected.connect(on_unit_deselected)
	visual_component.set_direction(Vector2.DOWN)
	name = "Unit" + str(get_parent().get_child_count())
	debug_name.text = "Name:" + name
	if is_dummy:
		construct_component.construct()
		navigation.set_enable(false)
		health_component.destructible = false
	pass

func do_action(data : SelectionManager.PointData):
	#print_debug(data)
	if is_dummy: return
	if data.object == self: return
	if data.object:
		if data.object.is_enemy:
			target_object(data.object)
		else:
			move_to_closest_position(data.position)
	else:
		move_to_position(data.position)
	pass

func move_to_position(pos : Vector2):
	#print_debug("move_to_position")
	set_state(State.MOVE)
	navigation.force_move_to_position(pos)
	combat_component.reset()
	pass

func move_to_closest_position(pos : Vector2):
	var new_pos = pos + Vector2(randf_range(-50,50),randf_range(-50,50))
	move_to_position(new_pos)
	pass

func target_object(obj : Node2D):
	#print_debug("target_object")
	navigation.target_object(obj)
	combat_component.set_target(obj)
	debug_target.text = "Target: " + obj.name
	pass

func on_velocity_computed(vel : Vector2):
	if state == State.ATTACK: return
	velocity = vel
	visual_component.set_direction(velocity.normalized())
	move_and_slide()
	pass

func on_position_reached():
	set_state(State.IDLE)
	velocity = Vector2.ZERO
	pass

func on_target_reached(target : PhysicsBody2D):
	set_state(State.IDLE)
	velocity = Vector2.ZERO
	target_object(target)
	pass

func on_combat_attack(target):
	set_state(State.ATTACK)
	debug_target.text = "Target: " + target.name
	pass

func set_state(new_state : State):
	if state == new_state: return
	#print_debug("State:" + str(State.keys()[new_state]))
	state = new_state
	debug_state.text = "State: " + str(State.keys()[state])
	state_update.emit(state)
	pass

func on_combat_end_attack():
	#print_debug("on_combat_end_attack")
	pass

func on_target_out_of_range(target : PhysicsBody2D):
	#print_debug("on_target_out_of_range")
	set_state(State.IDLE)
	target_object(target)
	pass

func on_health_update(_health, _max_health):
	print_debug("New health:" + str(_health) + " - Max Health:" + str(_max_health))
	pass

func on_health_dead():
	#print_debug("Dead!")
	destroy.emit(self)
	queue_free()
	pass

func take_damage(amount : float):
	health_component.take_damage(amount)
	pass

func on_target_update(target):
	if target:
		debug_target.text = "Target:" + target.name
	else:
		debug_target.text = "Target: No target"
	pass

func on_unit_selected():
	#set_state(State.SELECT)
	health_component.object_select_update(true)
	#merge_component.check_merge()
	pass # Replace with function body.

func on_unit_deselected():
	#set_state(State.IDLE)
	health_component.object_select_update(false)
	#merge_component.end_merge()
	pass # Replace with function body.

func on_health_hit():
	visual_component.hit()
	pass
