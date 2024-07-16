extends Node

var mana : float = 100

signal mana_update(mana)

func spend_card(card : Card):
	mana -= card.card_data.card_cost
	mana_update.emit(mana)
	pass
