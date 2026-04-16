extends Control

var card_id: String = ""
var cost_pa: int = 0
var cost_pb: int = 0

@onready var background    = $Background
@onready var rarity_frame  = $Rarity
@onready var artwork       = $Artwork
@onready var name_label    = $Name
@onready var cost_pa_label = $CostPA
@onready var cost_pb_label = $CostPB
@onready var desc_label    = $Description

signal card_clicked(card)

func setup(p_card_id: String, p_name: String, p_cost_pa: int, p_cost_pb: int, p_desc: String,
		bg_texture: Texture2D = null,
		rarity_texture: Texture2D = null,
		art_texture: Texture2D = null):

	card_id = p_card_id
	cost_pa = p_cost_pa
	cost_pb = p_cost_pb

	if name_label:    name_label.text    = p_name
	if cost_pa_label: cost_pa_label.text = str(p_cost_pa)
	if cost_pb_label: cost_pb_label.text = str(p_cost_pb)
	if desc_label:    desc_label.text    = p_desc

	if bg_texture and background:      background.texture   = bg_texture
	if rarity_texture and rarity_frame: rarity_frame.texture = rarity_texture
	if art_texture and artwork:         artwork.texture      = art_texture

	scale = base_scale

var is_hovered := false
var base_scale := Vector2(0.6, 0.6)

func _on_mouse_entered():
	is_hovered = true
	scale = Vector2(0.72, 0.72)
	z_index = 10

func _on_mouse_exited():
	is_hovered = false
	scale = base_scale
	z_index = 0

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_clicked", self)
