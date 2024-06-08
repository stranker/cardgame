class_name VisualComponent

extends Node2D

@export var construct_component : ConstructComponent

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
