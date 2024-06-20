class_name VisualComponent

extends Node2D

@export var construct_component : ConstructComponent
@export var sprites : Array[AnimatedSprite2D]
var last_direction : Vector2
var last_direction_processed : bool = false

func _ready():
	construct_component.construct_available.connect(_on_construct_available)
	construct_component.construct_unavailable.connect(_on_construct_unavailable)
	pass

func _on_construct_available():
	modulate = Color.WHITE
	pass

func _on_construct_unavailable():
	modulate = Color.RED
	pass

func set_direction(dir : Vector2):
	if dir.length_squared() == 0:
		_process_last_direction()
		return
	last_direction_processed = false
	_process_dir(dir)
	pass

func _process_last_direction():
	if last_direction_processed: return
	last_direction_processed = true
	for anim_sprite in sprites:
		if abs(last_direction.y) > abs(last_direction.x): # walking up or down
			if last_direction.y > 0.1:
				anim_sprite.play("idle_down")
			elif last_direction.y < -0.1:
				anim_sprite.play("idle_up")
		else:
			anim_sprite.play("idle_side")
	pass

func _process_dir(dir : Vector2):
	last_direction = dir
	for anim_sprite in sprites:
		if abs(dir.y) > abs(dir.x): # walking up or down
			if dir.y < -0.1:
				anim_sprite.play("walk_up")
			elif dir.y > 0.1:
				anim_sprite.play("walk_down")
			else:
				anim_sprite.play("idle_down")
		else:
			if dir.x < -0.1:
				anim_sprite.flip_h = true
				anim_sprite.play("walk_right")
			elif dir.x > 0.1:
				anim_sprite.flip_h = false
				anim_sprite.play("walk_right")
			else:
				anim_sprite.play("idle_side")
	pass
