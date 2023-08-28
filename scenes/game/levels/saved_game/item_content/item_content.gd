extends MarginContainer
## Clase que controla la celda de la tabla de avance guardado
##
## Cambia el efecto hover de la celda, activa los botones eliminar y cargar, resetea la celda a su estado inicial


# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

# Declaramos la ruta del estado a cargar
@export var scene_path : String
# Declaramos el nodo del padre
@export var parent : Node2D

# Declaramos el estado del elemento del grid
var selected = false


func _on_mouse_entered():
	# Validamos si no esta sseleccionado el elemento
	print("entro item content")
	if not selected:
		# Ajustamos la transparencia
		modulate.a8=200


func _on_mouse_exited():
	# Validamos si no esta sseleccionado el elemento
	if not selected:
		# Ajustamos la transparencia
		modulate.a8=255


func _on_pressed():
	# Llamamos la funcion que resetea los estados
	parent.clear()
	# Seteamos el estado como seleccionado
	selected = true
	# Ajustamos la transparencia
	modulate.a8=150
	parent.remove_button.visible = true
	parent.load_button.visible = true


func reset():
	# Seteamos el estado como no seleccionado
	selected = false
	# Ajustamos la transparencia
	modulate.a8=255
