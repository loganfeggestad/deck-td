extends CanvasLayer

@onready var draw_pile: Node2D = $DrawPile
@onready var hand: Node2D = $Hand
@onready var discard_pile: Node2D = $DiscardPile
@onready var draw_pile_button: Button = $DrawPile/DrawButton

func _ready() -> void:
	draw_pile_button.pressed.connect(_handle_draw_card)
	
	

func _process(_delta: float) -> void:
	pass

func _handle_draw_card() -> void:
	var card: CardData
	if (draw_pile.has_cards()):
		card = draw_pile.draw_next_card()
	else:
		discard_pile.shuffle()
		card = draw_pile.draw_next_card()
	hand.draw_card(card)

func discard(card: Card) -> void:
	var data: CardData = card.card_data
	print("discard received: ", card)
	print("valid: ", is_instance_valid(card))
	
	discard_pile.discard(data)
	send_card_to_discard_pile(card, discard_pile.global_position, func():
		print("callback card: ", card)
		print("callback valid: ", is_instance_valid(card))
		
		if (is_instance_valid(card)):
			card.queue_free()
	)

func shuffle_deck(discard_pile_cards: Array[CardData]) -> void:
	draw_pile.fill_and_shuffle_cards(discard_pile_cards)
	
#region Animations
func send_card_to_discard_pile(card: Card, discard_pos: Vector2, on_complete: Callable) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(card, "scale", Vector2.ONE, .5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(card, "global_position", discard_pos, 1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	var random_rotation = randf_range(-0.15, 0.15)
	tween.tween_property(card, "rotation", random_rotation, 0.4)
	
	tween.set_parallel(false)
	tween.tween_callback(on_complete)
#endregion
#region Signals
func _on_hand_discard_card_signal(card: Card) -> void:
	discard(card)

func _on_discard_pile_shuffle_deck_signal(discard_pile_cards: Array[CardData]) -> void:
	shuffle_deck(discard_pile_cards)
#endregion
