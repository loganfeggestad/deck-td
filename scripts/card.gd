@tool
class_name Card extends Node2D

#region Ready Values
@onready var card_base: Sprite2D = $CardFront/CardBase
@onready var card_image: Sprite2D = $CardFront/Image/ImageSprite
@onready var card_name: Label = $CardFront/CardNameLabel
@onready var card_description: Label = $CardFront/CardDescriptionLabel
@onready var card_front: Node2D = $CardFront
@onready var card_back: Node2D = $CardBack
@onready var area_2d: Area2D = $Area2D
@onready var energy_sprites: Array[Sprite2D] = [
	$CardFront/Energy/Sticker_1,
	$CardFront/Energy/Sticker_2,
	$CardFront/Energy/Sticker_3
]
#endregion
#region Card Value
var name_text: String = "":
	set(value):
		name_text = value
		if (is_node_ready() and card_name):
			card_name.text = name_text

var description_text: String = "":
	set(value):
		description_text = value
		if (is_node_ready() and card_description):
			card_description.text = description_text
			
var energy: int = 0:
	set(value):
		energy = value
		if (is_node_ready() and energy_sprites):
			for i in energy_sprites.size():
				energy_sprites[i].visible = (i + 1 == energy)
				
var image_sprite: Texture2D:
	set(value):
		image_sprite = value
		if(is_node_ready() and card_image):
			card_image.texture = image_sprite
#endregion

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

var card_data: CardData;

var is_dragging: bool = false;
var mouse_offset: Vector2 = Vector2.ZERO
var baseline_position: Vector2 = Vector2.ZERO
var baseline_rotation: float = 0.0;
var baseline_z_idx: int = 0

func _ready() -> void:
	update_visuals()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - mouse_offset

func setup(data: CardData) -> void:
	card_data = data
	
	name_text = data.card_name
	description_text = data.description
	energy = data.energy
	image_sprite = data.card_image_sprite
	
func update_visuals() -> void:
	card_name.text = name_text
	card_description.text = description_text
	card_image.texture = image_sprite
	for i in energy_sprites.size():
		energy_sprites[i].visible = (i + 1 == energy)

func _on_area_2d_mouse_entered():
	mouse_entered.emit(self)

func _on_area_2d_mouse_exited():
	mouse_exited.emit(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			mouse_offset = get_global_mouse_position() - global_position

func set_baselines() -> void:
	baseline_position = global_position
	baseline_rotation = rotation
	baseline_z_idx = z_index

func set_hovered_visual(is_hovered: bool):
	if (is_hovered):
		scale = Vector2(3, 3)
		global_position = Vector2(baseline_position.x, 1080 - (card_base.texture.get_size().y * 1.5))
		rotation = 0.0
		z_index = 1
	else:
		scale = Vector2(2, 2)
		global_position = baseline_position
		rotation = baseline_rotation
		z_index = baseline_z_idx
