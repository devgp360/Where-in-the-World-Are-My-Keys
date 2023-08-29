extends Node2D
## Clase que controla la puerta 
## 
## Muestra la puerta cuando el rompecabezas de Maximón está resuelto, abre y cierra la puerta, escucha eventos de colisión de la puerta con el ratón, muestra etiquetas en la puerta


# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s

# Señal para poder abrir/cerrar la puerta
signal toggle_opened_closed()

# Referencia al "puzzle" de "Maximón", para detectar cuando ya se finalizó
@export var puzzle: Node2D

# Indica si la puerta está abierta o cerrada
var _is_open = false

# Valida si se puede abrir o cerrar la puerta
# Solo se activa, cuando el personaje está cerca de la puerta
var _is_active = false

# Variables para animación y texto de la puerta
@onready var anim := $AnimationPlayer
@onready var label := $Label
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Called when the node enters the scene tree for the first time.
func _ready():
	toggle_opened_closed.connect(_toggle_opened_closed)
	puzzle.add_ended_game(ended_game)
	visible = false


# Al dar clic en la puerta
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("click"):
		_toggle_opened_closed()


# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Detecta cuando el personaje se acerca a la puerta
func _on_door_area_area_entered(area):
	if area.name == "mainchar_area":
		_is_active = true


# Detecta cuando el personaje se aleja de la puerta
func _on_door_area_area_exited(area):
	if area.name == "mainchar_area":
		_is_active = false


# Entramos (mouse) en el área de la puerta
func _on_door_area_mouse_entered():
	if not _is_active:
		return
	_set_label_text()
	label.visible = true


# Salimos (mouse) del el área de la puerta
func _on_door_area_mouse_exited():
	label.visible = false


# Mostrar texto de "entrar/abrir"
func _set_label_text():
	if _is_open:
		label.text = "Entrar"
	else:
		label.text = "Abrir"


# Mostrar/Ocultar la puerta al "ganar" el puzzle
func _toggle_opened_closed():
	if not _is_active:
		return
		
	if _is_open:
		SceneTransition.change_scene("res://scenes/game/levels/rooms/scene_3/scene_3.tscn")
	else:
		_is_open = true
		anim.play("open")


# Al "resolver" el puzzle, mostrar la puerta
func ended_game():
	self.visible = true
