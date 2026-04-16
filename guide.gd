extends Control

@onready var content_label = $BasesScrollContainer/BasesVBoxContainer/MarginContainer/ContentLabel

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _ready():
	show_bases()

func show_bases():
	content_label.text = """
	Vous vous apprêtez à vous lancer dans un Tactical Deck Builder. 
	
	Aidé par votre divinité, vous devrez traverser plusieurs actes composés de rencontres successives afin d’atteindre votre objectif final : affronter et vaincre Melkor.
	
	Chaque campagne est unique :
	
	Choisissez une vénération (divinité) qui influencera votre aventure, formez votre groupe de départ, progressez de rencontre en rencontre et adaptez votre stratégie en fonction des événements.
	
	Une partie se termine soit par votre victoire finale, soit par la mort de votre groupe.
	
	Traversez cinq actes composés de 30 rencontres pour avoir une chance dde venir à bout des forces du mal."""

func show_personnages():
	content_label.text = """
	Vous commencez chaque campagne avec 2 personnages de la race de votre choix parmis les suivantes : Noldor, Teleri, Edain, Nain. 
	Chaque race possède ses propres forces et mécaniques, disponibles lors de la création de votre duo de départ.
	
	Chaque personnage possède plusieurs attributs.
	Les points de vitalité représentent la vie du personnage. Ils sont réinitialisés à chaque nouvel acte. S'ils tombent à 0, votre personnage meurt définitivement.
	Les points d'action (PA) sont utilisés pour jouer vos cartes. Ils sont la ressource principale pour jouer vos cartes, et sont réinitialisés à chaque tour.
	Les points de bravoure (PB) servent à utiliser des pouvoirs raciaux ou jouer des cartes plus puissantes. Ils sont réinitialisés à chaque combat. 
	Vos personnages possèdent 4 emplacement d'équipement : 1 armure, 2 mains et un consommable. Au départ, vos personnages commencent avec un armure légère, une épée courte et un bouclier.
	
	Lorsqu'un personnage abtient assez d'expérience, il gagne un niveau. Vous pouvez alors choisir d'augmenter ses points d'action ou de bravoure."""

func show_rencontres():
	content_label.text = """
	Votre aventure sera composée de différentes rencontres.
	Les combats, qui sont des affrontements classiques contre des ennemis.
	Les combats d'élite, qui sont des combats plus difficiles, mais avec des récompenses plus intéressantes.
	Les villes, qui vous permettront de recruter, d'acheter de meilleurs équipements, de vous soigner ou encore de modifier votre deck.
	Les évènements spéciaux vous amèneront à rencontrer des personnages célèbres dans l'univers de Tolkien. Ces interactions vous permettront d'obtenir des butins exclusifs, de vous mesurer à des ennemis coriaces, et bien d'autres choses.
	
	Chaque fin d'acte est marquée par la rencontre avec un boss. Optimisez votre groupe pour leur faire face et accéder à la suite de l'aventure.
	"""

func show_combat():
	content_label.text = """
	Les combats se déroulent sur une grille de 2 lignes x 3 colonnes par équipe. 
	
	Déroulement d'un tour : 
	1- Vous piochez des cartes
	2- Jouez vos cartes en utilisant les PA/PB de vos personnages. Adaptez vous aux actions de vos ennemis, que vous pourrez prévisualiser en passant votre curseur sur eux.
	3- Lorsque votre main est vide ou que vos personnages ne peuvent plus jouer les cartes que vous avez en main, passez votre tour.
	4- Les ennemis attaquent
	
	Positionnement : placez vos unités de manière à mettre vos personnages capables d'encaisser les coups sur la première ligne. Si vous déplacez un ennemi, il perdra son tour. Si vous déplacez un de vos personnage avec vos cartes, vous pouvez éviter les attaques adverses.
	
	Les cartes : Vous commencez avec des cartes de base, mais vous pourrez étoffer votre deck pendant votre aventure. Vous piochez vos cartes dans un deck commun à tous vos personnages. Certaines cartes sont universelles, tandis que d'autres sont propres à une race ou liées aux équipements portés par vos personnages. Une fois le deck vide, votre défausse est mélangée et devient le nouveau deck. 
	Certaines cartes sont limitées à une utilisation par combat, elles seront ensuite bannies jusqu'au prochain combat. 
	
	Protégez vos unités fragiles, gérez vos ressources et anticipez les actions de vos ennemis pour en venir à bout."""

func show_carte():
	content_label.text = """
	Chaque acte est composé d'une série de 20 rencontres. Vous ne voyez qu'une partie de la carte, qui se dévoilera au fur et à mesure de votre progression. 
	
	Au bout de chaque acte, vous affronterez un boss, et à la fin de l'acte final, vous ferez face à Melkor."""

func _on_bases_button_pressed():
	show_bases()

func _on_perso_button_pressed():
	show_personnages()

func _on_rencontres_button_pressed():
	show_rencontres()

func _on_combat_button_pressed():
	show_combat()

func _on_carte_button_pressed():
	show_carte()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://combat_tutorial.tscn")
