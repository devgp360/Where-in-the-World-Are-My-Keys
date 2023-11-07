extends Node2D
## Clase que controla la escena "Ruinas de iglesia"
##
## Tiene eventos para cambiar hacia otras escenas


func _on_area_to_scene_tikal_body_entered(body):
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/tikal/tikal_interior.tscn")


func _on_area_to_scene_3_body_entered(body):
	# Redireccionamos a la escena Tikal
	SceneTransition.change_scene("res://scenes/game/levels/rooms/scene_3/scene_3.tscn")
