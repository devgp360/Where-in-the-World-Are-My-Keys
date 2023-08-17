extends CharacterBody2D

@onready var anim := $NPCAnimationPlayer
@onready var area2d := $Area2D
@onready var sprite := $npc1_sprite
@onready var sound := $AudioStreamPlayer2D
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
