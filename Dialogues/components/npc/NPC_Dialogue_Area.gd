extends Node2D
# DOCUMENTACIÓN ¿QUÉ SON LAS SEÑALES EN GDSCRIPT?: https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo

# El NPC, es el que tendrá un diálogo cargado, para comunicarse con el personaje principal
@export var dialogue_resource: DialogueResource
#Definición del inicio del diálogo
@export var dialogue_start: String = "start"
#Definición del template del diálogo
@export var Balloon: PackedScene
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

#Definición de la señal del diálogo
signal talk()
#Definición de la señal del diálogo terminado
signal dialogue_ended()

func _ready():
	#Inicialización del diálogo
	talk.connect(show_dialogue)

func show_dialogue():
	#Inicialización del template del diálogo
	var balloon: Node = (Balloon).instantiate()
	#Agtregar el código inicaliazado a la escena
	get_tree().current_scene.add_child(balloon)
	#Abrir diálogo
	balloon.start(dialogue_resource, dialogue_start)
	balloon._add_dialogue_ended(npc_dialogue_ended)

# Se emite la señal de finalización del diálogo
func npc_dialogue_ended():
	self.emit_signal("dialogue_ended")
	
# Se añade evento para escuchar cuando el diálogo finalice
func add_dialogue_ended(fn):
	dialogue_ended.connect(fn)
