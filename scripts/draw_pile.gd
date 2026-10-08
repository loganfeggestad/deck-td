extends Node2D

@onready var draw_pile_button: Button = $DrawButton
@onready var card_scene: PackedScene = preload("res://scenes/card.tscn")

var draw_pile: Array[CardData] = []

func _ready() -> void:
	for i in range(5):
		var data = CardData.new()
		data.card_name = "Card: " + str(i)
		data.energy = randi_range(1, 3)
		draw_pile.append(data)
	draw_pile.shuffle()

func _process(_delta: float) -> void:
	pass

func draw_next_card() -> CardData:
	var next_card: CardData = draw_pile.front()
	draw_pile.erase(next_card)
	return next_card
	
func fill_and_shuffle_cards(deck: Array[CardData]) -> void:
	for card in deck:
		draw_pile.append(card)
	draw_pile.shuffle()
	
func has_cards() -> bool:
	return draw_pile.size() > 0
