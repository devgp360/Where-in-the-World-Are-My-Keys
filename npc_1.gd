extends CharacterBody2D
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN TOOLTIPS PARA DIÁLOGOS CON NPCS: https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0

@onready var anim := $NPCAnimationPlayer
@onready var area2d := $Area2D
@onready var sprite := $npc1_sprite
@onready var sound := $AudioStreamPlayer2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Referencia al personaje principal
@export var mainchar: CharacterBody2D
# Area de contacto, para mostrar el diálogo
var npc_dialogue_area: Node2D
# Señal que se emite, cuando se finaliza la conversación
signal end_conversation()
# Determina el estado del diálogo (activo o inactivo)
var dialog_active = false

# Función de inicialización
func _ready():
	npc_dialogue_area = find_child("NPC_Dialogue_Area") # Buscamos el area de diálogo

func _physics_process(delta):
	#Iniciamos la animacion del NPC
	anim.play("idle1")

func _on_npc_1_area_area_exited(area):
	#Seteamos variable del dialogo a false al abandonar el area
	dialog_active = false
	#Emitimos señal de finalización de dialogo al abandonar el area
	mainchar.emit_signal("end_conversation")

func _on_dialog_timer_timeout():
	#Seteamos variable del dialogo a false
	dialog_active = false
	#Emitimos señal de finalización de dialogo
	mainchar.emit_signal("end_conversation")

func _on_npc_1_area_area_entered(name):
	#validamos si NPC interactua con la ventana del inventario
	if name.name != "Area2D":
		#Reproducimos el audio
		sound.play()

# Se usa para poder "escuchar" cuando el diálgo finaliza
func add_dialogue_ended(fn):
	if npc_dialogue_area:
		npc_dialogue_area.add_dialogue_ended(fn)
