extends NavigationRegion2D

signal map_event(event)

func _ready():
	ConstructManager.construct_success.connect(_on_construct_success)
	map_event.connect(SelectionManager.on_map_event)
	pass # Replace with function body.

func _on_construct_success(card : Card):
	if card.card_data.card_type == ConstructManager.ConstructType.BUILDING:
		bake_navigation_polygon()
	pass

func _input(event : InputEvent):
	if event.is_action("right_click"):
		if event.is_pressed():
			map_event.emit(event)
