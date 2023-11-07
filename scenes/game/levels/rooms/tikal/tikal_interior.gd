extends Node2D
## Clase que controla la escena "Tikal"
##
## Tiene eventos para cambiar hacia otras escenas



func _on_area_to_fire_body_entered(body):
	# Redireccionamos a la escena "Fuego"
	SceneTransition.change_scene("res://scenes/game/levels/rooms/fire/fire.tscn")


func _on_area_to_church_body_entered(body):
	# Redireccionamos a la escena "Iglesia"
	SceneTransition.change_scene("res://scenes/game/levels/rooms/church/church_interior.tscn")
