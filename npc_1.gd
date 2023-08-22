extends CharacterBody2D
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN TOOLTIPS PARA DIÁLOGOS CON NPCS: https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0

# DOCUMENTACIÓN (npc's): https://docs.google.com/document/d/1afPyT9PEDT_jkJKqAoq8BPkS0DMzl3DTtptRQDk_ME8/edit?usp=drive_link

@onready var anim := $NPCAnimationPlayer
@onready var area2d := $npc1_area
@onready var sprite := $npc1_sprite
@onready var sound := $AudioStreamPlayer2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

@export var vared: Node2D;

# Referencia al personaje principal
@export var mainchar: CharacterBody2D
# Area de contacto, para mostrar el diálogo
var npc_dialogue_area: Node2D
# Señal que se emite, cuando se finaliza la conversación
signal end_conversation()
# Determina el estado del diálogo (activo o inactivo)
var dialog_active = false

var count_test = 1

# Función de inicialización
func _ready():
	npc_dialogue_area = find_child("NPC_Dialogue_Area") # Buscamos el area de diálogo

func _physics_process(delta):
	#Iniciamos la animacion del NPC
	anim.play("idle1")
	#print("procesando físicas NPC: ", count_test)
	count_test += 1

# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
func _on_npc_1_area_area_exited(area):
	#Seteamos variable del dialogo a false al abandonar el area
	dialog_active = false
	#Emitimos señal de finalización de dialogo al abandonar el area
	mainchar.emit_signal("end_conversation")

func _on_npc_1_area_area_entered(name):
	#validamos si NPC interactua con la ventana del inventario
	if name.name != "Area2D":
		#Reproducimos el audio
		sound.play()

# DOCUMENTACIÓN (señales): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
# Se usa para poder "escuchar" cuando el diálgo finaliza
func add_dialogue_ended(fn):
	if npc_dialogue_area:
		npc_dialogue_area.add_dialogue_ended(fn)

