extends Node2D
## Clase que controla la escena "Ruinas de iglesia"
##
## Tiene eventos para cambiar hacia otras escenas

# Definición del nodo de menu
@export var pause_menu: PackedScene

# Definición del nodo main character
@onready var character = $ObjectsAndCharacter/MainCharacter


# Función que se llama cuando la escena esta cargada
func _ready():
	# Seteamos datos iniciales
	SaveProgress.set_level_data(character)
	MenuGlobal.set_process(false)


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


func _on_area_to_scene_tikal_body_entered(body):
	# Desbloqueamos la siguiente escena
	SaveProgress.save_active_scene("TikalRoom")
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/tikal/tikal_interior.tscn")


func _on_area_to_scene_3_body_entered(body):
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/scene_3/scene_3.tscn")


# Obtenemos datos de la escena (para guardado de avance)
func get_save_data():
	return SaveProgress.generate_save_data(character, "Church", 
		"res://scenes/game/levels/rooms/church/church_interior.tscn")
