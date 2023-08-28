extends Node2D
## Clase que controla el altar de Maximón
##
## Escucha finalización del diálogo y muestra el altar de Maximón

# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s

@export var puzzle: Node2D
@export var npc: CharacterBody2D

@onready var player = $AnimationPlayer
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	visible = false # Ocultamos el altar
	npc.on_dialogue_ended(_on_dialog_ended) # Ponemos a escuchar cuando se termine el diálogo con el NPC


# Para mostrar el puzzle
func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_pressed("click"):
		puzzle._set_visible(true)


# Cuando se termine de dialogar, mostrar un "altar" para acceder al puzzle
func _on_dialog_ended():
	visible = true
	player.play("show")
