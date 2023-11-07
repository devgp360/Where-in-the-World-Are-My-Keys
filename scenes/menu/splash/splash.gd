extends Node2D
## Clase que controla la escena principal (Splash) 
## 
## Setea los niveles de sonido guardados, cambia la escena actual por mapa global del juego, hace animación de logos, dueños del juego 


# DOCUMENTACIÓN (¿Como hacer Splash?): https://docs.google.com/document/d/11u22RhuGheb0z2ZpwwRgEygSr7kwTPtBme_17SZQwtw
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E

# Animation players
@onready var AnimationPlayerGP360: AnimationPlayer = $AnimationPlayerGP360
@onready var AnimationPlayerEndless: AnimationPlayer = $AnimationPlayerEndless

# Ruta a la escena a cargar cuando finalice el "splash"
@export var path_map_scene = "res://scenes/game/levels/rooms/map/map.tscn"


# Función que se llama cuando la escena esta cargada
func _ready():
	# Setamos los niveles de sonidos
	_set_sounds_volume()
	# Mostramos el logo de Endless
	AnimationPlayerEndless.play("do_splash")


# Escuchamos el teclado
func _input(event):
	# Escuchamos si se preciona algun boton
	if event is InputEventKey:
		# Llamamos el la función de cambio de escena
		_go_title_screen()

# Cuando termina la animación de logo Endless
func _on_animation_player_endless_animation_finished(anim_name):
	# Mostramos el logo de GP360
	AnimationPlayerGP360.play("do_splash")
	
	
# Cuando termina la animación de logo GP360
func _on_animation_player_gp_360_animation_finished(_anim_name):
	# Llamamos el la funcion de cambio de escena
	_go_title_screen()


# Función que inicializa el volumen de los sonidos (según datos guardados)
func _set_sounds_volume():
	# Cargamos los datos guardados
	var data = SaveProgress.load_game()
	# Validamos si existen los datos
	if (data):
		# Seteamos el nivel de sonido de la música
		Global.music_vol = data.sound.music
		# Seteamos el nivel de sonido de los sonidos de personaje principal
		Global.main_character_vol = data.sound.main_character
		# Seteamos el nivel de sonido de los sonidos de NPC
		Global.npc_vol = data.sound.npc
		# Recorremos todos los tipos de sonidos disponibles
		for sound_type in data.sound:
			var volume = data.sound[sound_type] # Volumen del sonido
			var chanel = AudioServer.get_bus_index(sound_type) # Canal de sonido
			# Seteamos el volumen del sonido
			AudioServer.set_bus_volume_db(chanel, linear_to_db(volume))


# Redirect a la escena de Mapa
func _go_title_screen():
	# Pasamos a la escena de Menú principal
	get_tree().change_scene_to_file(path_map_scene)
