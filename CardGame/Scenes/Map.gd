extends NavigationRegion2D

func _ready():
	ConstructManager.construct_success.connect(_on_construct_success)
	pass # Replace with function body.

func _on_construct_success(card : Card):
	if card.card_data.card_type == ConstructManager.ConstructType.BUILDING:
		bake_navigation_polygon()
	pass
