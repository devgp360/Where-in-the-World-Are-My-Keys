extends Node2D
## Clase que controla la escena "Fuente"
##
## Tiene eventos para cambiar hacia otras escenas


# Definición del nodo main character
@onready var character = $MainCharacter


# Función que se llama cuando la escena esta cargada
func _ready():
	# Seteamos datos iniciales
	SaveProgress.set_level_data(character)
	MenuGlobal.set_process(true)


func _on_area_to_fire_body_entered(body):
	# Redireccionamos a la escena 1
	SceneTransition.change_scene("res://scenes/game/levels/rooms/fire/fire.tscn")


# Obtenemos datos de la escena (para guardado de avance)
func get_save_data():
	return SaveProgress.generate_save_data(character, "Source", 
		"res://scenes/game/levels/rooms/source/source.tscn")
