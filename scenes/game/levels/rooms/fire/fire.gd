extends Node2D
## Clase que controla la escena "Fuego"
##
## Tiene eventos para cambiar hacia otras escenas

# Definición del nodo main character
@onready var character = $MainCharacter

# Función que se llama cuando la escena esta cargada
func _ready():
	# Seteamos datos iniciales
	SaveProgress.set_level_data(character)
	MenuGlobal.set_process(true)


func _on_area_to_tikal_body_entered(body):
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/tikal/tikal_interior.tscn")


func _on_area_to_source_body_entered(body):
	# Redireccionamos a la escena Fuente
	SceneTransition.change_scene("res://scenes/game/levels/rooms/source/source.tscn")


# Obtenemos datos de la escena
func get_save_data():
	return SaveProgress.generate_save_data(character, "Fire", 
		"res://scenes/game/levels/rooms/fire/fire.tscn")

