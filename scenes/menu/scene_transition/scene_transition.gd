extends CanvasLayer
## Clase que maneja tranciciones entre escenas
##
## Cambia la escena actual por la siguiente


# DOCUMENTACIÓN (cambio de escenas): https://docs.google.com/document/d/1FciThS6B4qQEBely2iCMDfkRZIzwSrZLCo2Fu8nE5LQ/edit?usp=drive_link
# DOCUMENTACIÓN (cambio de escenas: efectos): https://docs.google.com/document/d/1p8XxiMuEjBamnHwIY4R1jz_qHIWRW_iEULqOyBvCORA/edit?usp=drive_link

# Definición del AnimationPlayer
@onready var animation_player = $AnimationPlayer
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Cambio de la escena
func change_scene(target: String):
	# Agregamos la animación de "aparecer progresivamente", se muestra un cuadro de color
	animation_player.play("dissolve")
	# Esperamos a que termine la animación
	await animation_player.animation_finished
	# Cargamos la nueva escena (todavía se muestra el cuadro de color)
	get_tree().change_scene_to_file(target)
	# Agregamos la animación de "desaparecer progresivamente", se quita el cuadro de color
	animation_player.play_backwards("dissolve")
