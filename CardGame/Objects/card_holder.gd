extends Node2D

class_name CardHolder

@onready var card_scene = preload("res://Objects/Cards/card.tscn")
@export var cards_offset_x : float = 20
@export var cards_parent : Node2D
var cards : Array[Card]
var half_screen_center : Vector2
var concentration_factor : float = 1
var max_cards : int = 12
var unit = preload("res://Objects/Cards/unit_data.tres")
var house = preload("res://Objects/Cards/house_data.tres")

func _ready():
	ConstructManager.construct_success.connect(on_construct_success)
	ConstructManager.construct_failed.connect(on_construct_failed)
	half_screen_center = get_viewport_rect().size * 0.5
	#global_position.x = half_screen_center.x

	#_create_card(house)
	#_create_card(house)
	#_create_card(unit)
	#_create_card(unit)
	#_create_card(unit)
	#_create_card(unit)
	_create_card(unit)
	_create_card(unit)
	_create_card(unit)
	pass

func _create_card(data : CardData):
	var card : Card = card_scene.instantiate() as Card
	card.card_picked.connect(_on_card_picked)
	card.card_dropped.connect(_on_card_dropped)
	card.card_highligthed.connect(_on_card_highligted)
	cards_parent.add_child(card)
	cards.append(card)
	card.set_data(data)
	_arrange_cards()
	pass

func _arrange_cards():
	if cards.is_empty(): return
	concentration_factor = max(1 - (cards.size() / float(max_cards)), 0.4)
	var half_cards_x_offset = cards_offset_x * 0.5
	var half_card_size = cards[0].get_size_x() * 0.5
	var offset_x = (half_cards_x_offset + half_card_size) * concentration_factor
	var init_pos_x = global_position.x - (offset_x * (cards.size() - 1)) 
	for card in cards:
		card.set_new_position(Vector2(init_pos_x, global_position.y))
		init_pos_x += (cards[0].get_size_x() + cards_offset_x) * concentration_factor
	pass

func _on_card_picked(card : Card):
	for hand_card in cards:
		if card != hand_card:
			hand_card.disabled()
	pass

func _on_card_dropped(card : Card):
	for hand_card in cards:
		if card != hand_card:
			hand_card.enable()
	pass

func on_construct_failed(card : Card):
	card.reset()
	for hand_card in cards:
		hand_card.enable()
	pass

func on_construct_success(card : Card):
	for hand_card in cards:
		if card != hand_card:
			hand_card.enable()
	cards.erase(card)
	card.queue_free()
	_arrange_cards()
	pass

func _on_card_highligted(card : Card):
	cards_parent.move_child(card, cards_parent.get_child_count() - 1)
	pass


func _on_card_deck_button_down():
	_create_card(unit)
	pass # Replace with function body.
