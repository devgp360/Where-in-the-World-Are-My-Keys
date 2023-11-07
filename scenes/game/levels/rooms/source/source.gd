extends Node2D
## Clase que controla la escena "Fuente"
##
## Tiene eventos para cambiar hacia otras escenas


func _on_area_to_fire_body_entered(body):
	# Redireccionamos a la escena 1
	SceneTransition.change_scene("res://scenes/game/levels/rooms/fire/fire.tscn")
