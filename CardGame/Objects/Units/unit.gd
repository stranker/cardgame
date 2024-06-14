class_name Unit

extends CharacterBody2D

@onready var navigation : NavigationComponent = $NavigationComponent
@onready var combat_component : CombatComponent = $CombatComponent
@onready var health_component : HealthComponent = $HealthComponent
@export var is_enemy : bool = false
@export var debug_state : Label
@export var debug_target : Label
@export var speed : float = 200
@export var damage : float = 1
@export var attack_speed : float = 1
@export var health : float = 10
@export var max_health : float = 10

enum State { IDLE, MOVE, ATTACK, FOLLOW }
var state : State = State.IDLE

signal dead_unit(unit)

func _ready():
	dead_unit.connect(SelectionManager.on_dead_unit)
	navigation.init(speed)
	navigation.velocity_computed.connect(on_velocity_computed)
	navigation.target_reached.connect(on_target_reached)
	navigation.position_reached.connect(on_position_reached)
	combat_component.end_attack.connect(on_combat_end_attack)
	combat_component.attack.connect(on_combat_attack)
	combat_component.target_out_of_range.connect(on_target_out_of_range)
	combat_component.init(damage, attack_speed)
	health_component.init(health, max_health)
	health_component.health_update.connect(on_health_update)
	health_component.dead.connect(on_health_dead)
	pass

func do_action(data : SelectionManager.PointData, multiple_selection : bool):
	#if state == State.ATTACK: return
	if data.object == self: return
	if data.object:
		target_object(data.object)
	else:
		move_to_position(data.position)
	pass

func move_to_position(pos : Vector2):
	navigation.force_move_to_position(pos)
	pass

func target_object(obj : Node2D):
	navigation.target_object(obj)
	debug_target.text = "Target: " + obj.name
	pass

func on_velocity_computed(vel : Vector2):
	if state == State.ATTACK: return
	set_state(State.MOVE)
	velocity = vel
	move_and_slide()
	pass

func on_position_reached():
	set_state(State.IDLE)
	velocity = Vector2.ZERO
	pass

func on_target_reached(target : PhysicsBody2D):
	velocity = Vector2.ZERO
	combat_component.attack_target(target)
	pass

func on_combat_attack(target):
	set_state(State.ATTACK)
	debug_target.text = "Target: " + target.name
	pass

func set_state(new_state : State):
	#print_debug("State:" + str(State.keys()[new_state]))
	debug_state.text = "State: " + str(State.keys()[new_state])
	state = new_state
	pass

func on_combat_end_attack():
	print_debug("on_combat_end_attack")
	set_state(State.IDLE)
	debug_target.text = "Target: No target"
	pass

func on_target_out_of_range(target : PhysicsBody2D):
	set_state(State.IDLE)
	target_object(target)
	pass

func on_health_update(_health, _max_health):
	print_debug("New health:" + str(_health) + " - Max Health:" + str(_max_health))
	pass

func on_health_dead():
	print_debug("Dead!")
	dead_unit.emit(self)
	queue_free()
	pass

func take_damage(amount : float):
	health_component.take_damage(amount)
	pass
