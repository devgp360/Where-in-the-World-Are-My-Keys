extends Node2D
## Clase que controla sonidos 
##
## Hace efecto de cambio de sonido suave, apaga sonidos, escucha colisiones con áreas

#Definición del nodo Sonidos
@onready var sound1 = $Sounds/Track1
@onready var sound2 = $Sounds/Track2
@onready var anim_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#Transiciones entre audios
func crossfade_to(audio_stream: AudioStream, soundNum: int):
	#Si los dos audios estan sonando retornamos
	if sound1.playing and sound2.playing:
		print("salimos")
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	#Validamos si el segundo sonido esta sonando
	if soundNum == 1 && !sound1.playing:
		#Creamos el stream para el reproductor 1
		sound1.stream = audio_stream
		#Reproducimos el sonido 1
		sound1.play()
		print("Scene1")
		#Iniciamos la animacion de Fade
		anim_player.play("FadeToTrack1")
	elif soundNum == 2 && !sound2.playing:
		print("Scene2")
		#Creamos el stream para el reproductor 2
		sound2.stream = audio_stream
		#Reproducimos el sonido 2
		sound2.play()
		#Iniciamos la animacion de Fade
		anim_player.play("FadeToTrack2")
		
func stopSound(audio: AudioStreamPlayer2D):
	#Paramos la reprodución
	audio.stop()
	
func _on_area_left_area_entered(_area):
	#Cargamos el audio 1
	var vstream = load("res://assets/sounds/Scene1.mp3")
	#Llamamos la funcion de transiciones entre audios
	crossfade_to(vstream, 1)

func _on_area_right_area_entered(_area):
	#Cargamos el audio 2
	var vstream = load("res://assets/sounds/Scene2.mp3")
	#Llamamos la funcion de transiciones entre audios
	crossfade_to(vstream, 2)

func _on_animation_player_animation_finished(anim_name):
	#Validamos que animación terminó
	if anim_name == "FadeToTrack1":
		#Pausamos el audio 2
		sound2.stop()
	elif anim_name == "FadeToTrack2":
		#Pausamos el audio 1
		sound1.stop()
