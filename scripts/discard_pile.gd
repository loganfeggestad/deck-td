extends Node2D

var discard_pile: Array[CardData] = []

signal shuffle_deck_signal(discard_pile: Array[CardData])

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
func shuffle() -> void:
	print("Shuffled Deck")
	
	shuffle_deck_signal.emit(discard_pile)
	
	discard_pile.clear()
	pass
	
func discard(card: CardData) -> void:
	discard_pile.append(card)
