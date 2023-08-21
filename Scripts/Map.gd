extends Node2D
# DOCUMENTACIÓN CREAR UN MAPA GENERAL: https://docs.google.com/document/d/1q-aOyPNZ2Ldn6hH9H43Ym6u_fmWvujVgbkHfayPDN-E
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E
# DOCUMENTACIÓN CREACIÓN DE UN AMBIENTE ISOMÉTRICO CON IA GENERATIVA: https://docs.google.com/document/d/17CxEvaKcvUjWci0zHjMCGg8CYKW0BQiz7PwMXvJrdnA

#Declaración de la escena de Menú principal
@export var PauseMenu: PackedScene
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

#Declaración del canal de audio activo
var bus_index: int

# Función que se llama cuando la escena esta cargada
func _ready():
	#Configuramos el nivel de sonidos
	set_audio()

# Función que siempre se llama
func _process(delta):
	#Validamos si presionamos el boton Escape
	if(Input.is_action_pressed("ui_cancel")):
		#Pausamos el juego
		get_tree().paused = true
		#Cargamos el nodo de Menú
		var pause: Node = (PauseMenu).instantiate()
		#Mostramos el nodo del Menú
		get_tree().current_scene.add_child(pause)

#Función para setearlos niveles de audio
func set_audio():
	#Definimos los tipos de audios
	var bus = ["music","mainCharacter","npc"]
	#Recorremos cada tipo de audio
	for i in bus.size():
		#Buscamos el index del tipo de audio
		bus_index = AudioServer.get_bus_index(bus[i])
		#Seteamos el nivel del sonido
		AudioServer.set_bus_volume_db(bus_index,linear_to_db(Global[bus[i] + "Vol"]))
	