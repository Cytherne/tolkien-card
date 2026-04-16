extends Control

@onready var hand_container = $Hand/HandContainer
@onready var card_scene = preload("res://carte.tscn")


func _on_button_pressed():
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://guide.tscn")
	
@export var max_visible_cards := 5
@export var card_width := 120
@export var spacing := 140

func arrange_cards():
	var cards = hand_container.get_children()
	var count = cards.size()
	if count == 0:
		return

	# largeur de la main si pas de chevauchement
	var full_width = (count - 1) * spacing

	# zone max "idéale" (5 cartes sans overlap)
	var max_width = (max_visible_cards - 1) * spacing

	# si trop de cartes → on réduit l'espacement
	var final_spacing = spacing
	if count > max_visible_cards:
		final_spacing = max_width / float(count - 1)

	var total_width = (count - 1) * final_spacing

	# centrage horizontal
	var start_x = -total_width / 2

	for i in range(count):
		var card = cards[i]

		var x = start_x + i * final_spacing
		var y = 0

		card.position = Vector2(x, y)

		# carte la plus à droite au-dessus
		card.z_index = i

func _ready():
	arrange_cards()
	spawn_test_cards()

func spawn_test_cards():
	# ⚔️ Épée
	var card1 = card_scene.instantiate()
	hand_container.add_child(card1)
	card1.setup(
		"Épée test",
		1,
		0,
		"Inflige 5 dégâts."
	)

	# 🛡️ Bouclier
	var card2 = card_scene.instantiate()
	hand_container.add_child(card2)
	card2.setup(
		"Bouclier test",
		1,
		0,
		"Donne 5 armure."
	)

	arrange_cards()





	
