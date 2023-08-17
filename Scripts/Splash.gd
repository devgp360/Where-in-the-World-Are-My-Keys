extends Node2D


# Función que se llama cuando la escena esta cargada
func _ready():
	#Setamos los niveles de sonidos
	setSoundsVolume()
	pass # Replace with function body.

	
func setSoundsVolume():
	#Cargamos los datos guardados
	var data = SaveProgress.load_game()
	#Validamos si existen los datos
	if (data):
		#Seteamos el nivel de sonido de la música
		Global.musicVol = data.sound.music
		#Seteamos el nivel de sonido de los sonidos de personaje principal
		Global.mainCharacterVol = data.sound.mainCharacter
		#Seteamos el nivel de sonido de los sonidos de NPC
		Global.npcVol = data.sound.npc
		#Creamos el arreglo de tipos de sonidos
		var bus = ["music","mainCharacter","npc"]
		#Recorremos cada tipo de sonido
		for i in bus.size():
			#Obtenemos el canal de sonido
			var music = AudioServer.get_bus_index(bus[i])
			#Seteamos el volumen del sonido
			AudioServer.set_bus_volume_db(music,linear_to_db(data.sound[bus[i]]))

#Redirect a la escena de Mapa
func go_title_screen():
	#Pasamos a la escena de Menú principal
	get_tree().change_scene_to_file("res://Map.tscn")

#Escuchamos el teclado
func _input(event):
	#Escuchamos si se preciona algun boton
	if(event is InputEventKey):
		#Llamamos el la funcion de cambio de escena
		go_title_screen()

#Cuando termina la animación
func _on_animation_player_animation_finished(anim_name):
	#Llamamos el la funcion de cambio de escena
	go_title_screen()
