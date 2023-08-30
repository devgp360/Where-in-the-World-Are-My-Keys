extends CharacterBody2D
## Clase que controla el comportamiento de NPC
##
## Controla los dialogos con el personaje principal, escucha coliciones

# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN TOOLTIPS PARA DIÁLOGOS CON NPCS: https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0
# DOCUMENTACIÓN (npc's): https://docs.google.com/document/d/1afPyT9PEDT_jkJKqAoq8BPkS0DMzl3DTtptRQDk_ME8/edit?usp=drive_link

# Referencia al personaje principal
@export var mainchar: CharacterBody2D

# Area de contacto, para mostrar el diálogo
var _npc_dialogue_area: Node2D
# Determina el estado del diálogo (activo o inactivo)
var _dialog_active = false

# Variables para control de animación, áreas, sprites y sonidos
@onready var anim := $NPCAnimationPlayer
@onready var area2d := $NpcArea
@onready var sprite := $NpcSprite
@onready var sound := $AudioStreamPlayer2D
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	_npc_dialogue_area = find_child("NpcDialogueArea") # Buscamos el area de diálogo
	anim.play("idle1")


# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Función cuando un área entra en contacto con el NPC. _area: es el área que hace contacto
func _on_npc_1_area_area_exited(_area):
	# Seteamos variable del dialogo a false al abandonar el area
	_dialog_active = false


# Función cuando un área sale del contacto con el NPC
func _on_npc_1_area_area_entered(_area):
	# Validamos si NPC interactua con la ventana del inventario
	if _area.name != "Area2D":
		# Reproducimos el audio
		sound.play()


# DOCUMENTACIÓN (señales): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
# Se usa para poder "escuchar" cuando el diálgo finaliza
func on_dialogue_ended(fn):
	if _npc_dialogue_area:
		_npc_dialogue_area.on_dialogue_ended(fn)
