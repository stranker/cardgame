class_name MergeComponent

extends Area2D

@export var type : int = 0
@export var level : int = 0
@export var max_level : int = 0

signal merge_intended(obj)
signal remove_merge(obj)
signal try_merge()

func _ready():
	monitoring = false
	area_entered.connect(on_merge_enter)
	area_exited.connect(on_merge_exited)
	merge_intended.connect(MergeManager.on_merge_intended)
	remove_merge.connect(MergeManager.on_merge_remove)
	try_merge.connect(MergeManager.on_try_merge)
	pass

func check_merge():
	monitoring = true
	pass

func end_merge():
	monitoring = false
	try_merge.emit()
	pass

func on_merge_enter(area : Area2D):
	var merge_area = area as MergeComponent
	if can_merge_with(merge_area):
		merge_intended.emit(get_parent())
		merge_area.check_merge()
	pass

func can_merge_with(other : MergeComponent):
	return type == other.type and level == other.level

func on_merge_exited(area : Area2D):
	remove_merge.emit(self)
	pass
