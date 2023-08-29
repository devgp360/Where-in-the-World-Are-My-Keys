extends Node2D
## Clase que controla sonidos 
##
## Hace efecto de cambio de sonido suave, apaga sonidos, escucha colisiones con áreas


# Definición del nodo Sonidos
@onready var sound_1 = $Sounds/Track1
@onready var sound_2 = $Sounds/Track2
@onready var anim_player := $AnimationPlayer


func _on_area_left_area_entered(_area):
	# Cargamos el audio 1
	var vstream = load("res://assets/sounds/scene_1.mp3")
	# Llamamos la funcion de transiciones entre audios
	_crossfade_to(vstream, 1)


func _on_area_right_area_entered(_area):
	# Cargamos el audio 2
	var vstream = load("res://assets/sounds/scene_2.mp3")
	# Llamamos la funcion de transiciones entre audios
	_crossfade_to(vstream, 2)


func _on_animation_player_animation_finished(anim_name):
	# Validamos que animación terminó
	if anim_name == "FadeToTrack1":
		# Pausamos el audio 2
		sound_2.stop()
	elif anim_name == "FadeToTrack2":
		# Pausamos el audio 1
		sound_1.stop()


# Transiciones entre audios
func _crossfade_to(audio_stream: AudioStream, sound_num: int):
	# Si los dos audios estan sonando retornamos
	if sound_1.playing and sound_2.playing:
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	# Validamos si el segundo sonido esta sonando
	if sound_num == 1 and not sound_1.playing:
		# Creamos el stream para el reproductor 1
		sound_1.stream = audio_stream
		# Reproducimos el sonido 1
		sound_1.play()
		# Iniciamos la animacion de Fade
		anim_player.play("FadeToTrack1")
	elif sound_num == 2 and not sound_2.playing:
		# Creamos el stream para el reproductor 2
		sound_2.stream = audio_stream
		# Reproducimos el sonido 2
		sound_2.play()
		# Iniciamos la animacion de Fade
		anim_player.play("FadeToTrack2")
