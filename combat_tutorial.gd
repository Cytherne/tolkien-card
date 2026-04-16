extends Control

# ════════════════════════════════════════════════════════════════════════════
#  COMBAT TUTORIAL - Script principal
# ════════════════════════════════════════════════════════════════════════════

@onready var hand_container   = $Hand/HandContainer
@onready var deck_count_label = $Deck/DeckCount
@onready var end_turn_button  = $EndTurnButton
@onready var tutorial_bubble  = $TutorialBubble
@onready var tutorial_text    = $TutorialBubble/MarginContainer/TutorialText
@onready var board            = $Board

var card_scene       = preload("res://carte.tscn")
var personnage_scene = preload("res://personnage.tscn")
var ennemi_scene     = preload("res://ennemi.tscn")

@export var max_visible_cards := 5
@export var spacing := 140

# ─── Définitions des cartes ──────────────────────────────────────────────────
const CARD_DEFINITIONS = {
	"coup_rapide": { "name": "Coup Rapide", "pa": 1, "pb": 0, "desc": "Inflige 5 dégâts à un ennemi." },
	"blocage":     { "name": "Blocage",     "pa": 1, "pb": 0, "desc": "Ajoute 5 armure à ce personnage." },
	"esquive":     { "name": "Esquive",     "pa": 1, "pb": 1, "desc": "Déplace ce personnage sur une case vide alliée." },
}

# ─── Deck / Défausse / Main ──────────────────────────────────────────────────
var deck:       Array = []
var discard:    Array = []
var hand_cards: Array = []

const FIRST_HAND = ["esquive", "blocage", "blocage", "coup_rapide", "coup_rapide"]
var first_turn: bool = true

# ─── Personnages & Ennemis ────────────────────────────────────────────────────
var noldor_node = null
var edain_node  = null
var roklem_node = null

# ─── État de sélection ───────────────────────────────────────────────────────
# Flux : joueur clique sur un personnage → selected_character est défini
#        puis clique sur une carte → selected_card est défini + effet résolu
#        Pour Coup Rapide : attend un clic sur l'ennemi
#        Pour Esquive     : attend un clic sur une case alliée vide
enum SelectionState {
	NONE,              # rien de sélectionné
	CHARACTER_SELECTED, # un personnage est sélectionné, attend une carte
	WAITING_TARGET_ENEMY, # carte Coup Rapide jouée, attend clic ennemi
	WAITING_TARGET_CASE,  # carte Esquive jouée, attend clic case vide
}
var selection_state: SelectionState = SelectionState.NONE
var selected_character = null   # personnage_node sélectionné
var selected_card      = null   # carte_node sélectionnée

# ─── État du jeu ─────────────────────────────────────────────────────────────
enum GameState { TUTORIAL_BUBBLE, PLAYER_TURN, ENEMY_TURN, COMBAT_END }
var game_state: GameState = GameState.TUTORIAL_BUBBLE

# ─── Tutoriel ─────────────────────────────────────────────────────────────────
var tutorial_messages = [
	"L'ennemi vous attaque : Passez votre souris sur l'ennemi pour visualiser ses cibles et ses dégâts !",
	"Votre Noldor possède 1 PB, vous pouvez esquiver l'attaque.",
	"Votre Edain ne peut pas esquiver : Utilisez 'Blocage' pour absorber les dégâts qui arrivent.",
	"Utilisez vos PA restants pour infliger des dégâts.",
	"Lorsque vous avez terminé votre tour, cliquez sur le bouton 'Fin de tour' !"
]
var tutorial_index: int = 0

# ════════════════════════════════════════════════════════════════════════════
#  _READY
# ════════════════════════════════════════════════════════════════════════════
func _ready():
	_init_deck()
	_spawn_characters()
	_spawn_enemy()
	_deal_first_hand()
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	end_turn_button.disabled = true
	_show_tutorial_bubble()

# ════════════════════════════════════════════════════════════════════════════
#  DECK MANAGEMENT
# ════════════════════════════════════════════════════════════════════════════
func _init_deck():
	deck = ["esquive", "esquive",
			"coup_rapide", "coup_rapide", "coup_rapide", "coup_rapide",
			"blocage", "blocage", "blocage", "blocage"]
	discard = []
	deck.shuffle()
	_update_deck_count()

func _update_deck_count():
	if deck_count_label:
		deck_count_label.text = str(deck.size())

func _draw_card() -> String:
	if deck.is_empty():
		_reshuffle()
	if deck.is_empty():
		return ""
	var cid = deck.pop_front()
	_update_deck_count()
	return cid

func _reshuffle():
	deck = discard.duplicate()
	discard.clear()
	deck.shuffle()
	_update_deck_count()

func _deal_first_hand():
	var to_deal = FIRST_HAND.duplicate()
	for cid in to_deal:
		var idx = deck.find(cid)
		if idx != -1:
			deck.remove_at(idx)
	for cid in to_deal:
		_add_card_to_hand(cid)
	_update_deck_count()
	arrange_cards()

func _deal_cards(count: int):
	for i in range(count):
		var cid = _draw_card()
		if cid != "":
			_add_card_to_hand(cid)
	arrange_cards()

func _add_card_to_hand(cid: String):
	var def = CARD_DEFINITIONS[cid]
	var card = card_scene.instantiate()
	hand_container.add_child(card)
	card.setup(cid, def["name"], def["pa"], def["pb"], def["desc"])
	card.card_clicked.connect(_on_card_clicked.bind(card))
	hand_cards.append(card)

func _discard_hand():
	for card in hand_cards:
		if is_instance_valid(card):
			discard.append(card.card_id)
			card.queue_free()
	hand_cards.clear()

func arrange_cards():
	var cards = hand_container.get_children()
	var count = cards.size()
	if count == 0:
		return
	var max_width = (max_visible_cards - 1) * spacing
	var final_spacing = spacing
	if count > max_visible_cards:
		final_spacing = max_width / float(count - 1)
	var total_width = (count - 1) * final_spacing
	var start_x = -total_width / 2
	for i in range(count):
		cards[i].position = Vector2(start_x + i * final_spacing, 0)
		cards[i].z_index = i

# ════════════════════════════════════════════════════════════════════════════
#  SPAWN PERSONNAGES & ENNEMIS
# ════════════════════════════════════════════════════════════════════════════
func _spawn_characters():
	noldor_node = personnage_scene.instantiate()
	board.add_child(noldor_node)
	noldor_node.setup("Noldor", "Noldor")
	_place_on_case(noldor_node, "CaseA1")
	noldor_node.gui_input.connect(_on_personnage_input.bind(noldor_node))

	edain_node = personnage_scene.instantiate()
	board.add_child(edain_node)
	edain_node.setup("Edain", "Edain")
	_place_on_case(edain_node, "CaseA4")
	edain_node.gui_input.connect(_on_personnage_input.bind(edain_node))

func _spawn_enemy():
	roklem_node = ennemi_scene.instantiate()
	board.add_child(roklem_node)
	roklem_node.setup("Roklem")
	_place_on_case(roklem_node, "CaseE1")
	roklem_node.hovered.connect(_on_enemy_hovered)
	roklem_node.enemy_died.connect(_on_enemy_died)
	roklem_node.gui_input.connect(_on_roklem_input)

func _place_on_case(node: Control, case_name: String):
	var case_node = board.get_node_or_null(case_name)
	if case_node:
		node.position = case_node.position + case_node.size / 2.0 - node.custom_minimum_size / 2.0

# ════════════════════════════════════════════════════════════════════════════
#  TUTORIEL BULLES
# ════════════════════════════════════════════════════════════════════════════
func _show_tutorial_bubble():
	game_state = GameState.TUTORIAL_BUBBLE
	end_turn_button.disabled = true
	tutorial_text.text = tutorial_messages[tutorial_index]
	tutorial_bubble.visible = true

func _next_tutorial_or_play():
	tutorial_index += 1
	if tutorial_index < tutorial_messages.size():
		tutorial_text.text = tutorial_messages[tutorial_index]
	else:
		tutorial_bubble.visible = false
		_start_player_turn()

func _input(event: InputEvent):
	if not (event is InputEventMouseButton and event.pressed):
		return
	match game_state:
		GameState.TUTORIAL_BUBBLE:
			_next_tutorial_or_play()
		GameState.COMBAT_END:
			get_tree().change_scene_to_file("res://guide.tscn")

# ════════════════════════════════════════════════════════════════════════════
#  TOUR DU JOUEUR
# ════════════════════════════════════════════════════════════════════════════
func _start_player_turn():
	game_state = GameState.PLAYER_TURN
	end_turn_button.disabled = false
	_clear_selection()
	if noldor_node and is_instance_valid(noldor_node):
		noldor_node.restore_pa()
		noldor_node.reset_armor()
	if edain_node and is_instance_valid(edain_node):
		edain_node.restore_pa()
		edain_node.reset_armor()
	if not first_turn:
		_deal_cards(5)
	first_turn = false

func _on_end_turn_pressed():
	if game_state != GameState.PLAYER_TURN:
		return
	_clear_selection()
	_discard_hand()
	arrange_cards()
	end_turn_button.disabled = true
	game_state = GameState.ENEMY_TURN
	await get_tree().create_timer(0.8).timeout
	_enemy_turn()

# ════════════════════════════════════════════════════════════════════════════
#  TOUR DE L'ENNEMI
# ════════════════════════════════════════════════════════════════════════════
func _enemy_turn():
	if not roklem_node or not is_instance_valid(roklem_node) or roklem_node.current_pdv <= 0:
		return
	var actions = roklem_node.get_planned_actions()
	for action in actions:
		if action["targets"] == "all_allies":
			var dmg = action["damage"]
			if noldor_node and is_instance_valid(noldor_node) and noldor_node.current_pdv > 0:
				noldor_node.receive_damage(dmg)
			if edain_node and is_instance_valid(edain_node) and edain_node.current_pdv > 0:
				edain_node.receive_damage(dmg)
	if _all_allies_dead():
		_end_combat(false)
		return
	await get_tree().create_timer(0.5).timeout
	_start_player_turn()

func _all_allies_dead() -> bool:
	var n_dead = not noldor_node or not is_instance_valid(noldor_node) or noldor_node.current_pdv <= 0
	var e_dead = not edain_node or not is_instance_valid(edain_node) or edain_node.current_pdv <= 0
	return n_dead and e_dead

# ════════════════════════════════════════════════════════════════════════════
#  SÉLECTION PERSONNAGE → CARTE
# ════════════════════════════════════════════════════════════════════════════

# Étape 1 : clic sur un personnage
func _on_personnage_input(event: InputEvent, perso):
	if game_state != GameState.PLAYER_TURN:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	# Si on attend déjà une cible → annuler
	if selection_state == SelectionState.WAITING_TARGET_ENEMY or selection_state == SelectionState.WAITING_TARGET_CASE:
		_clear_selection()
		return
	# Sélectionner ce personnage
	if perso.current_pdv <= 0:
		return
	_clear_selection()
	selected_character = perso
	selection_state = SelectionState.CHARACTER_SELECTED
	perso.set_selected(true)
	# Mettre en surbrillance les cartes jouables par ce personnage
	_highlight_playable_cards(perso)

# Étape 2 : clic sur une carte (après avoir sélectionné un personnage)
func _on_card_clicked(card):
	if game_state != GameState.PLAYER_TURN:
		return
	# Si aucun personnage sélectionné → ignorer
	if selection_state != SelectionState.CHARACTER_SELECTED or selected_character == null:
		# Feedback visuel : flash orange "sélectionnez d'abord un personnage"
		_flash_card_error(card)
		return
	var perso = selected_character
	# Vérifier que ce personnage peut payer
	if not perso.can_pay(card.cost_pa, card.cost_pb):
		_flash_card_error(card)
		return
	selected_card = card
	match card.card_id:
		"blocage":
			# Effet immédiat : pas de cible à choisir
			perso.pay_cost(card.cost_pa, card.cost_pb)
			perso.add_armor(5)
			_send_to_discard(card)
			_clear_selection()
		"coup_rapide":
			# Attend clic sur ennemi
			selection_state = SelectionState.WAITING_TARGET_ENEMY
			_highlight_enemies(true)
		"esquive":
			# Attend clic sur case vide alliée
			selection_state = SelectionState.WAITING_TARGET_CASE
			_highlight_empty_cases(true)

# Étape 3a : clic sur Roklem (Coup Rapide)
func _on_roklem_input(event: InputEvent):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if selection_state != SelectionState.WAITING_TARGET_ENEMY:
		return
	var perso = selected_character
	var card  = selected_card
	if perso and is_instance_valid(perso) and card and is_instance_valid(card):
		perso.pay_cost(card.cost_pa, card.cost_pb)
		roklem_node.receive_damage(5)
		_send_to_discard(card)
	_highlight_enemies(false)
	_clear_selection()

# Étape 3b : clic sur une case vide (Esquive)
# Les cases connectent leur signal via _connect_case_inputs()
func _on_case_clicked(case_name: String):
	if selection_state != SelectionState.WAITING_TARGET_CASE:
		return
	var case_node = board.get_node_or_null(case_name)
	if case_node == null:
		return
	# Vérifier que la case est libre
	var target_pos = case_node.position + case_node.size / 2.0 - selected_character.custom_minimum_size / 2.0
	if _is_case_occupied(target_pos, selected_character):
		return
	var perso = selected_character
	var card  = selected_card
	if perso and is_instance_valid(perso) and card and is_instance_valid(card):
		perso.pay_cost(card.cost_pa, card.cost_pb)
		perso.position = target_pos
		_send_to_discard(card)
	_highlight_empty_cases(false)
	_clear_selection()

func _is_case_occupied(target_pos: Vector2, exclude) -> bool:
	for other in [noldor_node, edain_node]:
		if other == exclude or not is_instance_valid(other):
			continue
		if (other.position - target_pos).length() < 20.0:
			return true
	return false

# ─── Connexion des inputs des cases ──────────────────────────────────────────
var _cases_connected := false

func _connect_case_inputs():
	if _cases_connected:
		return
	_cases_connected = true
	var ally_cases = ["CaseA1","CaseA2","CaseA3","CaseA4","CaseA5","CaseA6"]
	for cn in ally_cases:
		var case_node = board.get_node_or_null(cn)
		if case_node:
			case_node.mouse_filter = Control.MOUSE_FILTER_STOP
			case_node.gui_input.connect(_on_case_input.bind(cn))

func _on_case_input(event: InputEvent, case_name: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_case_clicked(case_name)

# ════════════════════════════════════════════════════════════════════════════
#  HELPERS SÉLECTION / HIGHLIGHT
# ════════════════════════════════════════════════════════════════════════════
func _clear_selection():
	selection_state = SelectionState.NONE
	if selected_character and is_instance_valid(selected_character):
		selected_character.set_selected(false)
	selected_character = null
	selected_card = null
	_highlight_playable_cards(null)
	_highlight_enemies(false)
	_highlight_empty_cases(false)

func _highlight_playable_cards(perso):
	for card in hand_cards:
		if not is_instance_valid(card):
			continue
		if perso == null:
			card.modulate = Color(1, 1, 1)
		elif perso.can_pay(card.cost_pa, card.cost_pb):
			card.modulate = Color(1, 1, 1)         # jouable → normal
		else:
			card.modulate = Color(0.5, 0.5, 0.5)  # non jouable → grisée

func _highlight_enemies(on: bool):
	if roklem_node and is_instance_valid(roklem_node):
		roklem_node.set_targeted(on)

func _highlight_empty_cases(on: bool):
	_connect_case_inputs()
	var ally_cases = ["CaseA1","CaseA2","CaseA3","CaseA4","CaseA5","CaseA6"]
	for cn in ally_cases:
		var case_node = board.get_node_or_null(cn)
		if case_node == null:
			continue
		if on:
			# Vérifie si la case est libre
			var target_pos = case_node.position + case_node.size / 2.0 - selected_character.custom_minimum_size / 2.0
			var occupied = _is_case_occupied(target_pos, selected_character)
			case_node.modulate = Color(0.5, 1.0, 0.5) if not occupied else Color(1, 1, 1)
		else:
			case_node.modulate = Color(1, 1, 1)

# ════════════════════════════════════════════════════════════════════════════
#  UTILITAIRES
# ════════════════════════════════════════════════════════════════════════════
func _send_to_discard(card):
	if not is_instance_valid(card):
		return
	discard.append(card.card_id)
	hand_cards.erase(card)
	card.queue_free()
	arrange_cards()

func _flash_card_error(card):
	if not is_instance_valid(card):
		return
	var orig = card.modulate
	card.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(card):
		card.modulate = orig

# ════════════════════════════════════════════════════════════════════════════
#  PREVIEW ATTAQUE ENNEMIE (hover)
# ════════════════════════════════════════════════════════════════════════════
func _on_enemy_hovered(_enemy, is_hov: bool):
	var show = is_hov and game_state == GameState.PLAYER_TURN
	if noldor_node and is_instance_valid(noldor_node):
		noldor_node.show_damage_preview(show and noldor_node.current_pdv > 0, 5)
	if edain_node and is_instance_valid(edain_node):
		edain_node.show_damage_preview(show and edain_node.current_pdv > 0, 5)

# ════════════════════════════════════════════════════════════════════════════
#  FIN DE COMBAT
# ════════════════════════════════════════════════════════════════════════════
func _on_enemy_died(_enemy):
	_end_combat(true)

func _end_combat(victory: bool):
	game_state = GameState.COMBAT_END
	end_turn_button.disabled = true
	_clear_selection()
	tutorial_text.text = "🏆 Victoire ! Vous avez vaincu Roklem !\n\nCliquez pour retourner au menu." if victory \
		else "💀 Défaite... Vos personnages sont tombés.\n\nCliquez pour retourner au menu."
	tutorial_bubble.visible = true

func _on_button_pressed():
	get_tree().change_scene_to_file("res://guide.tscn")
