extends Node2D

# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s

@export var puzzle: Node2D
@export var npc: CharacterBody2D
@onready var player = $AnimationPlayer

# Función de inicialización
func _ready():
	visible = false
	npc.add_dialogue_ended(_on_dialog_ended)

# Cuando se termine de dialogar, mostrar un "altar" para acceder al puzzle
func _on_dialog_ended():
	visible = true
	player.play("show")

# Para mostrar el puzzle
func _on_area_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event.is_action_pressed("click"):
		puzzle._set_visible(true)
