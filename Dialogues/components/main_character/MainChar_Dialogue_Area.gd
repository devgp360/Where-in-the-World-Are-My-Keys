extends Node2D
# DOCUMENTACIÓN ¿QUÉ SON LAS SEÑALES EN GDSCRIPT?: https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo

#Conexión del nodo Area2D
@export var external_area2d: Area2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Definición del nodo del NPC
var npc_dialogue_node: Node2D

# Definicion de la señal del dialogo
signal talk()

# Called when the node enters the scene tree for the first time.
func _ready():
	#Conexión del area de entrada al dialogo
	external_area2d.area_entered.connect(area_entered)
	#Conexión del area de salida al dialogo
	external_area2d.area_exited.connect(area_exited)

	#Inicio del dialogo
	talk.connect(show_dialogue)

func area_exited(area):
	#Resetar el dialogo
	npc_dialogue_node = null

func show_dialogue():
	#Validación de que hay que mostrar el dialogo
	if npc_dialogue_node:
		#Levantar el diálogo
		npc_dialogue_node.emit_signal("talk")

func area_entered(area):
	#En el caso que entremos al área de un NPC que tenga diálogos
	var child = area.find_child("NPC_Dialogue_Area")

	#Si se encuentra el NPC con diálogo
	if child:
		#Asignamos el diálogo encontrado al nodo del NPC
		npc_dialogue_node = child
		#Emitimos la señal para mostrar el diálogo
		npc_dialogue_node.emit_signal("talk")
