class_name Buildeable

extends PhysicsBody2D

@export var construct_component : ConstructComponent

func create():
	construct_component.create()
	pass

func ghost():
	construct_component.ghost()
	pass

func is_available():
	return construct_component.is_available()
