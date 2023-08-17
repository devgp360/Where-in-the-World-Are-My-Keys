extends Node2D

# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s

@onready var anim := $AnimationPlayer
@onready var label := $Label
@export var puzzle: Node2D

# Indica si la puerta está abierta o cerrada
var is_open = false

# Valida si se puede abrir o cerrar la puerta
# Solo se activa, cuando el personaje está cerca de la puerta
var is_active = false

signal toggle()

# Called when the node enters the scene tree for the first time.
func _ready():
	toggle.connect(toggle_door)
	puzzle.add_ended_game(ended_game)
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Mostrar/Ocultar la puerta al "ganar" el puzzle
func toggle_door():
	if !is_active:
		return
		
	if is_open:
		SceneTransition.change_scene("res://Scene3.tscn")
	else:
		is_open = true
		anim.play("open")
	
# Al dar clic en la puerta
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		toggle_door()

# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Detecta cuando el personaje se acerca a la puerta
func _on_door_area_area_entered(area):
	if area.name == "mainchar_area":
		is_active = true

# Detecta cuando el personaje se aleja de la puerta
func _on_door_area_area_exited(area):
	if area.name == "mainchar_area":
		is_active = false

# Entramos (mouse) en el área de la puerta
func _on_door_area_mouse_entered():
	if !is_active:
		return
	setLabelText()
	label.visible = true

# Salimos (mouse) del el área de la puerta
func _on_door_area_mouse_exited():
	label.visible = false

# Mostrar texto de "entrar/abrir"
func setLabelText():
	if is_open:
		label.text = "Entrar"
	else:
		label.text = "Abrir"

# Al "resolver" el puzzle, mostrar la puerta
func ended_game():
	self.visible = true
