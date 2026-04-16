extends Control

const RACE_DATA = {
	"Noldor": { "max_pdv": 25, "max_pa": 2, "max_pb": 1, "texture": "res://Noldor.png" },
	"Teleri": { "max_pdv": 25, "max_pa": 4, "max_pb": 0, "texture": "res://Teleri.png" },
	"Edain":  { "max_pdv": 30, "max_pa": 3, "max_pb": 0, "texture": "res://Edain.png"  },
	"Nain":   { "max_pdv": 30, "max_pa": 2, "max_pb": 0, "texture": "res://Nain.png"   },
}

@export var race: String = "Noldor"
@export var character_name: String = ""
@export var level: int = 1

var max_pdv: int = 25
var current_pdv: int = 25
var max_pa: int = 2
var current_pa: int = 2
var max_pb: int = 1
var current_pb: int = 1
var armor: int = 0

@onready var sprite          = $Sprite
@onready var name_label      = $NameLabel
@onready var pdv_label       = $StatsContainer/PDVLabel
@onready var pa_label        = $StatsContainer/PALabel
@onready var pb_label        = $StatsContainer/PBLabel
@onready var armor_label     = $StatsContainer/ArmorLabel
@onready var highlight       = $Highlight        # ColorRect rouge pour preview dégâts
@onready var select_outline  = $SelectOutline    # ColorRect vert pour sélection joueur
@onready var damage_preview  = $DamagePreview

signal character_died(character)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	refresh_ui()

func setup(p_race: String, p_name: String = ""):
	race = p_race
	character_name = p_name if p_name != "" else p_race
	if race in RACE_DATA:
		var d = RACE_DATA[race]
		max_pdv = d["max_pdv"]
		max_pa  = d["max_pa"]
		max_pb  = d["max_pb"]
		var tex = load(d["texture"]) as Texture2D
		if tex and sprite:
			sprite.texture = tex
	current_pdv = max_pdv
	current_pa  = max_pa
	current_pb  = max_pb
	armor = 0
	refresh_ui()

func refresh_ui():
	if name_label:
		name_label.text = character_name
	if pdv_label:
		pdv_label.text = "❤ %d/%d" % [current_pdv, max_pdv]
	if pa_label:
		pa_label.text = "PA: %d/%d" % [current_pa, max_pa]
	if pb_label:
		pb_label.text = "PB: %d/%d" % [current_pb, max_pb]
	if armor_label:
		armor_label.text = "🛡 %d" % armor
		armor_label.visible = armor > 0
	show_damage_preview(false, 0)

# ─── Sélection ────────────────────────────────────────────────────────────────
func set_selected(on: bool):
	if select_outline:
		select_outline.visible = on

# ─── Ressources ───────────────────────────────────────────────────────────────
func restore_pa():
	current_pa = max_pa
	refresh_ui()

func restore_pb():
	current_pb = max_pb
	refresh_ui()

func can_pay(cost_pa: int, cost_pb: int) -> bool:
	return current_pa >= cost_pa and current_pb >= cost_pb

func pay_cost(cost_pa: int, cost_pb: int):
	current_pa -= cost_pa
	current_pb -= cost_pb
	refresh_ui()

# ─── Combat ──────────────────────────────────────────────────────────────────
func receive_damage(amount: int):
	var effective = max(0, amount - armor)
	armor = max(0, armor - amount)
	current_pdv -= effective
	current_pdv = max(0, current_pdv)
	refresh_ui()
	if current_pdv <= 0:
		emit_signal("character_died", self)

func add_armor(amount: int):
	armor += amount
	refresh_ui()

func reset_armor():
	armor = 0
	refresh_ui()

# ─── Preview dégâts ennemis ───────────────────────────────────────────────────
func show_damage_preview(visible_flag: bool, damage: int = 0):
	if highlight:
		highlight.visible = visible_flag
	if damage_preview:
		damage_preview.visible = visible_flag
		if visible_flag:
			damage_preview.text = str(damage)
