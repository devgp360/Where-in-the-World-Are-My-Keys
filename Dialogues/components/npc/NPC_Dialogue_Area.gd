extends Node2D

# DOCUMENTACIÓN (diálogos entre personajes): https://docs.google.com/document/d/1LO1XeDq58IKrXyzbgeStl16No89CeKeArLRQyjY8oVk/edit?usp=drive_link
# DOCUMENTACIÓN (tooltips de diálogos): https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0/edit?usp=drive_link

# El NPC, es el que tendrá un diálogo cargado, para comunicarse con el personaje principal
@export var dialogue_resource: DialogueResource
#Definición del inicio del diálogo
@export var dialogue_start: String = "start"
#Definición del template del diálogo
@export var Balloon: PackedScene

#Definición de la señal del diálogo
signal talk()
#Definición de la señal del diálogo terminado
signal dialogue_ended()

# Función de inicialización
func _ready():
	#Inicialización del diálogo
	talk.connect(show_dialogue)

# Mostramos el diálogo
func show_dialogue():
	#Inicialización del template del diálogo
	var balloon: Node = (Balloon).instantiate()
	#Agtregar el código inicaliazado a la escena
	get_tree().current_scene.add_child(balloon)
	#Abrir diálogo
	balloon.start(dialogue_resource, dialogue_start)
	#Escuchamos cuando el diálogo termine
	balloon._add_dialogue_ended(npc_dialogue_ended)

# DOCUMENTACIÓN (señales): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
# Se emite la señal de finalización del diálogo
func npc_dialogue_ended():
	self.emit_signal("dialogue_ended")
	
# Se añade evento para escuchar cuando el diálogo finalice
func add_dialogue_ended(fn):
	dialogue_ended.connect(fn)
