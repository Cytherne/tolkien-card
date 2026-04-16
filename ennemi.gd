extends Control

const ENEMY_DATA = {
	"Roklem": {
		"max_pdv": 20,
		"texture": "res://Roklem.png",
		"attacks": [
			{ "targets": "all_allies", "damage": 5 }
		]
	},
}

@export var enemy_type: String = "Roklem"

var enemy_name: String = "Roklem"
var max_pdv: int = 20
var current_pdv: int = 20
var attacks: Array = []

@onready var sprite          = $Sprite
@onready var name_label      = $NameLabel
@onready var pdv_label       = $PDVLabel
@onready var highlight       = $Highlight     # orange : survol souris
@onready var target_outline  = $TargetOutline # rouge vif : ciblé par Coup Rapide

signal enemy_died(enemy)
signal hovered(enemy, is_hovered)

func setup(p_type: String):
	enemy_type = p_type
	if enemy_type in ENEMY_DATA:
		var d = ENEMY_DATA[enemy_type]
		enemy_name  = enemy_type
		max_pdv     = d["max_pdv"]
		current_pdv = max_pdv
		attacks     = d["attacks"]
		var tex = load(d["texture"]) as Texture2D
		if tex and sprite:
			sprite.texture = tex
	refresh_ui()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	refresh_ui()

func refresh_ui():
	if name_label:
		name_label.text = enemy_name
	if pdv_label:
		pdv_label.text = "❤ %d/%d" % [current_pdv, max_pdv]

func receive_damage(amount: int):
	current_pdv -= amount
	current_pdv = max(0, current_pdv)
	refresh_ui()
	if current_pdv <= 0:
		emit_signal("enemy_died", self)

func get_planned_actions() -> Array:
	return attacks.duplicate()

# Appelé par combat_tutorial pour indiquer que l'ennemi est ciblé (Coup Rapide)
func set_targeted(on: bool):
	if target_outline:
		target_outline.visible = on

func _on_mouse_entered():
	if highlight:
		highlight.visible = true
	emit_signal("hovered", self, true)

func _on_mouse_exited():
	if highlight:
		highlight.visible = false
	emit_signal("hovered", self, false)
