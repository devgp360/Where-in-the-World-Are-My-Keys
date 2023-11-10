extends Node2D
## Clase que controla la escena "Tikal"
##
## Tiene eventos para cambiar hacia otras escenas
## Hace efecto de cambio de sonido suave, apaga sonidos, escucha colisiones con áreas

# Definición del nodo de menu
@export var pause_menu: PackedScene
# Definición del nodo Sonidos
@onready var sound_1 = $Sounds/Track1
@onready var sound_2 = $Sounds/Track2
@onready var anim_player := $AnimationPlayer
# Definición del nodo main character
@onready var character = $Objects/MainCharacter

# Función que se llama cuando la escena esta cargada
func _ready():
	# Desbloqueamos la siguiente escena
	SaveProgress.save_active_scene("Iglesia")
	# Seteamos datos iniciales
	SaveProgress.set_level_data(character)
	# Habilitamos el menu
	MenuGlobal.set_process(true)


# Función que siempre se llama
func _process(_delta):
	# Levantamos el menú principal
	if Input.is_action_pressed("ui_cancel"):
		# Pausamos el juego
		get_tree().paused = true
		# Obtenemos el nodo de menú principal
		var pause: Node = pause_menu.instantiate()
		# Creamos Screenshot
		pause.img = get_viewport().get_texture().get_image()
		# Mostramos el menú
		get_tree().current_scene.add_child(pause)


func _on_area_to_fire_body_entered(body):
	# Redireccionamos a la escena "Fuego"
	SceneTransition.change_scene("res://scenes/game/levels/rooms/fire/fire.tscn")


func _on_area_to_church_body_entered(body):
	# Redireccionamos a la escena "Iglesia"
	SceneTransition.change_scene("res://scenes/game/levels/rooms/church/church_interior.tscn")


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


# Obtenemos datos de la escena
func get_save_data():
	return SaveProgress.generate_save_data(character, "Tikal", 
		"res://scenes/game/levels/rooms/tikal/tikal_interior.tscn")
