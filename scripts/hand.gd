extends Node2D
#region On Ready Variables
@onready var card_scene: PackedScene = preload("res://scenes/card.tscn")
#endregion
#region Constants
const hand_radius: int = 4000
const card_angle: float = -90
const angle_limit: float = 20
const max_card_spread_angle: float = 2.5
const max_hand_size: int = 10
const sticky_hover_distance: int = 20
const play_zone_threshold: int = 700
const card_reposition_anim_duration: float = 0.3
#endregion
#region Properties
var hand: Array[Card] = []
var hovered_cards: Array[Card] = []
@export var active_hovered_card: Card = null
#endregion
#region Signals
signal discard_card_signal(card: Card)
#endregion

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_update_active_hover()
				
func _update_active_hover() -> void:
	var closest_card: Card = null
	var min_distance: float = INF
	var mouse_pos = get_global_mouse_position()

	for card in hovered_cards:
		if card.is_animating(TweenTypes.TweenType.HAND_REPOSITION) or \
			card.is_animating(TweenTypes.TweenType.DRAW):
			continue
		
		var distance = mouse_pos.distance_to(card.global_position)
		
		if card == active_hovered_card:
			distance -= sticky_hover_distance
		
		if distance < min_distance:
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
		hand.push_front(card)
		card.mouse_entered.connect(_handle_card_hovered)
		card.mouse_exited.connect(_handle_card_un_hovered)
		reposition_hand(card)

func discard_card(card: Card) -> void:
	hovered_cards.erase(card)
	hand.erase(card)
	card.reparent(get_parent())
	discard_card_signal.emit(card)
	reposition_hand()

func reposition_hand(new_card: Card = null) -> void:
	var card_spread = min((angle_limit / hand.size()), max_card_spread_angle)
	var current_angle = -(card_spread * (hand.size() - 1)) / 2 - 90
	
	for i in range(hand.size()) :
		var card = hand[i]
		
		var target_position = get_card_position(current_angle)
		var target_rotation = deg_to_rad(current_angle + 90)
		
		if card == new_card:
			card.position = get_card_position(current_angle - card_spread * 3)
			
			_animate_draw_new_card(card, target_position, target_rotation)
		else:
			_animate_card_reposition(card, target_position, target_rotation)
		
		card.set_baselines()
		current_angle += card_spread
		
	if is_instance_valid(active_hovered_card):
		active_hovered_card.set_hovered_visual(true)

func get_card_position(angle_in_deg: float) -> Vector2:
	var x: float = hand_radius * cos(deg_to_rad(angle_in_deg))
	var y: float = hand_radius * sin(deg_to_rad(angle_in_deg)) + hand_radius
	
	return Vector2(int(x), int(y))

#region Animations
func _animate_card_reposition(card: Card, target_position: Vector2, target_rotation: float) -> void:
	var tween = create_tween()
	card.start_tween(TweenTypes.TweenType.HAND_REPOSITION, tween)
	
	tween.bind_node(card)
	tween.set_parallel(true)
	
	tween.tween_property(card, "position", target_position, card_reposition_anim_duration)
	tween.tween_property(card, "rotation", target_rotation, card_reposition_anim_duration)
	
	tween.set_parallel(false)
	tween.chain().tween_callback(func():
		card.finish_tween(TweenTypes.TweenType.HAND_REPOSITION, tween)
		card.set_baselines()
		_update_active_hover()
	)

func _animate_draw_new_card(card: Card, target_position: Vector2, target_rotation: float) -> void:
	var tween = create_tween()
	card.start_tween(TweenTypes.TweenType.DRAW, tween)
	
	tween.bind_node(card)
	tween.set_parallel(true)
	
	tween.tween_property(card, "position", target_position, card_reposition_anim_duration)
	tween.tween_property(card, "rotation", target_rotation, card_reposition_anim_duration)
	
	tween.set_parallel(false)
	tween.chain().tween_callback(func():
		card.finish_tween(TweenTypes.TweenType.DRAW, tween)
		card.set_baselines()
		_update_active_hover()
	)
#endregion

func _handle_card_hovered(card: Card) -> void:
	if not (hovered_cards.has(card)) and hand.has(card):
		hovered_cards.append(card)

func _handle_card_un_hovered(card: Card) -> void:
	hovered_cards.erase(card)
