extends Node2D

@onready var card_scene: PackedScene = preload("res://scenes/card.tscn")

const hand_radius: int = 4000
const card_angle: float = -90
const angle_limit: float = 20
const max_card_spread_angle: float = 2.5
const max_hand_size = 10
const sticky_hover_distance = 20
const play_zone_threshold: int = 700

signal discard_card_signal(card: Card)

var hand: Array[Card] = []

var hovered_cards: Array[Card] = []
var active_hovered_card: Card = null

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var closest_card = null
	var min_distance: float = INF
	var mouse_pos = get_global_mouse_position()
	
	if hovered_cards.size() == 1:
		var card = hovered_cards[0]
		min_distance = mouse_pos.distance_to(card.global_position)
		closest_card = card
	elif hovered_cards.size() > 1:
		for card in hovered_cards:
			
			var distance = mouse_pos.distance_to(card.global_position)
			if (card == active_hovered_card):
				distance -= sticky_hover_distance
				
			if (distance < min_distance):
				min_distance = distance
				closest_card = card
				
	if closest_card != active_hovered_card:
		_clear_active_hover()
		if closest_card != null:
			active_hovered_card = closest_card
			active_hovered_card.set_hovered_visual(true)
	
func _clear_active_hover() -> void:
	var card: Card = active_hovered_card
	active_hovered_card = null

	if is_instance_valid(card):
		if card.global_position.y <= play_zone_threshold:
			discard_card(card)
		else:
			card.set_hovered_visual(false)

func draw_card(data: CardData)-> void:
	if (hand.size() < 10 && data):
		
		var card = card_scene.instantiate()
		add_child(card)
		card.setup(data)
		hand.push_back(card)
		card.mouse_entered.connect(_handle_card_hovered)
		card.mouse_exited.connect(_handle_card_un_hovered)
		reposition_hand()

func discard_card(card: Card) -> void:
	print("HAND discard_card called: ", card)
	hovered_cards.erase(card)
	hand.erase(card)
	card.reparent(get_parent())
	discard_card_signal.emit(card)
	reposition_hand()

func reposition_hand() -> void:
	var card_spread = min((angle_limit / hand.size()), max_card_spread_angle)
	var current_angle = -(card_spread * (hand.size() - 1))/2 - 90
	for card in hand :
		_update_card_transform(card, current_angle)
		current_angle += card_spread
		card.set_baselines()

func get_card_position(angle_in_deg: float) -> Vector2:
	var x: float = hand_radius * cos(deg_to_rad(angle_in_deg))
	var y: float = hand_radius * sin(deg_to_rad(angle_in_deg)) + hand_radius
	
	return Vector2(int(x), int(y))

func _update_card_transform(card: Node2D, angle_in_drag: float) -> void:
	card.set_position(get_card_position(angle_in_drag))
	card.set_rotation(deg_to_rad(angle_in_drag + 90))
	
func _handle_card_hovered(card: Card) -> void:
	if not hovered_cards.has(card):
		hovered_cards.append(card)

func _handle_card_un_hovered(card: Card) -> void:
	hovered_cards.erase(card)
	#if (card == active_hovered_card):
		#_clear_active_hover()
