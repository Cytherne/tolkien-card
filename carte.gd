extends Control

@onready var background = $Background
@onready var rarity_frame = $RarityFrame
@onready var artwork = $Artwork

@onready var name_label = $Name
@onready var cost_pa_label = $CostPA
@onready var cost_pb_label = $CostPB
@onready var desc_label = $Description

func setup(card_name: String, cost_pa: int, cost_pb: int, desc: String,
		bg_texture: Texture2D = null,
		rarity_texture: Texture2D = null,
		art_texture: Texture2D = null):

	name_label.text = card_name
	cost_pa_label.text = str(cost_pa)
	cost_pb_label.text = str(cost_pb)
	desc_label.text = desc

	if bg_texture:
		background.texture = bg_texture

	if rarity_texture:
		rarity_frame.texture = rarity_texture

	if art_texture:
		artwork.texture = art_texture
	
	scale = base_scale



var is_hovered := false

func _on_mouse_entered():
	is_hovered = true
	scale = Vector2(1.1, 1.1)
	z_index = 10

func _on_mouse_exited():
	is_hovered = false
	scale = Vector2(1, 1)
	z_index = 0

var base_scale := Vector2(0.6, 0.6)
