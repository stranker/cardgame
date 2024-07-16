extends Node

var merge_list : Array = []

func on_merge_remove(body):
	if not merge_list.has(body): return
	merge_list.erase(body)
	pass

func on_merge_intended(body):
	if merge_list.has(body): return
	merge_list.append(body)
	pass

func merge_objects():
	for obj in merge_list:
		obj.queue_free()
	pass

func on_try_merge():
	if merge_list.size() > 2:
		merge_objects()
	pass
