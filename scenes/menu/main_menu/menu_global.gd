extends Node

# Definición del nodo de menu
var pause_menu: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	# Cargamos el recurso
	pause_menu = load("res://scenes/menu/main_menu/main_menu.tscn")


# Función que siempre se llama
func _process(_delta):
	# Levantamos el menú principal
	if Input.is_action_pressed("ui_cancel"):
		# Pausamos el juego
		get_tree().paused = true
		var pause: Node = pause_menu.instantiate()
		# Creamos Screenshot
		pause.img = get_viewport().get_texture().get_image()
		# Mostramos el menú
		get_tree().current_scene.add_child(pause)

