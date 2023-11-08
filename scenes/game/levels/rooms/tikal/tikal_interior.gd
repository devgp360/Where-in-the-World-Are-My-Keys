extends Node2D
## Clase que controla la escena "Tikal"
##
## Tiene eventos para cambiar hacia otras escenas

# Definición del nodo de menu
@export var pause_menu: PackedScene

# Función que se llama cuando la escena esta cargada
func _ready():
	# Desbloqueamos la siguiente escena
	SaveProgress.save_active_scene("Iglesia")


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
