extends Node2D
## Clase que controla la escena principal (Splash) 
## 
## Setea los niveles de sonido guardados, cambia la escena actual por mapa global del juego, hace animación de logos, dueños del juego 

# DOCUMENTACIÓN (¿Como hacer Splash?): https://docs.google.com/document/d/11u22RhuGheb0z2ZpwwRgEygSr7kwTPtBme_17SZQwtw
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E


# Función que se llama cuando la escena esta cargada
func _ready():
	#Setamos los niveles de sonidos
	setSoundsVolume()


#Escuchamos el teclado
func _input(event):
	#Escuchamos si se preciona algun boton
	if(event is InputEventKey):
		#Llamamos el la funcion de cambio de escena
		go_title_screen()


func setSoundsVolume():
	#Cargamos los datos guardados
	var data = SaveProgress.load_game()
	#Validamos si existen los datos
	if (data):
		#Seteamos el nivel de sonido de la música
		Global.music_vol = data.sound.music
		#Seteamos el nivel de sonido de los sonidos de personaje principal
		Global.main_character_vol = data.sound.main_character
		#Seteamos el nivel de sonido de los sonidos de NPC
		Global.npc_vol = data.sound.npc
		#Creamos el arreglo de tipos de sonidos
		var bus = ["music","main_character","npc"]
		#Recorremos cada tipo de sonido
		for i in bus.size():
			#Obtenemos el canal de sonido
			var music = AudioServer.get_bus_index(bus[i])
			#Seteamos el volumen del sonido
			AudioServer.set_bus_volume_db(music,linear_to_db(data.sound[bus[i]]))


#Redirect a la escena de Mapa
func go_title_screen():
	#Pasamos a la escena de Menú principal
	get_tree().change_scene_to_file("res://scenes/game/levels/rooms/map/map.tscn")


#Cuando termina la animación
func _on_animation_player_animation_finished(_anim_name):
	#Llamamos el la funcion de cambio de escena
	go_title_screen()
