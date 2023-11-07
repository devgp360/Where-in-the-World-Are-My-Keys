extends Node2D
## Clase que controla la escena "Fuego"
##
## Tiene eventos para cambiar hacia otras escenas


func _on_area_to_tikal_body_entered(body):
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/tikal/tikal_interior.tscn")


func _on_area_to_source_body_entered(body):
	# Redireccionamos a la escena Fuente
	SceneTransition.change_scene("res://scenes/game/levels/rooms/source/source.tscn")
