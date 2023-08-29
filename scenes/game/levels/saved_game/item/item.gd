extends TextureButton
## Clase que controla la celda de la tabla de avance guardado
##
## Obtiene el nombre de la escena guardada si existe, cambia el efecto hover de la celda, activa los botones auxiliares de confirmación, resetea la celda a su estado inicial


# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

# Declaramos la ruta del estado a cargar
@export var scene_path : String
# Declaramos el nodo del padre
@export var parent : Node2D
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Declaramos el estado del elemento del grid
var _selected = false
# Declaramos el estado de la celda
var empty = false
# Id de la escena
var id = ''
# Ruta de la escena
var path = ''
# Se permiten todas acciones
var _only_load = false


# Called when the node enters the scene tree for the first time.
func _ready():
	var scenes = ["Map"]
	var actual_scene = get_tree().get_current_scene().name
	if scenes.find(actual_scene, 0) > -1:
		_only_load = true


func _on_mouse_entered():
	# Validamos si no esta sseleccionado el elemento
	if not _selected:
		# Ajustamos la transparencia
		modulate.a8=200


func _on_mouse_exited():
	# Validamos si no esta sseleccionado el elemento
	if not _selected:
		# Ajustamos la transparencia
		modulate.a8=255


func _on_pressed():
	# Llamamos la funcion que resetea los estados
	parent.clear()
	# Seteamos el estado como seleccionado
	_selected = true
	# Ajustamos la transparencia
	modulate.a8=150
	Global.active_item_menu_id = id
	Global.item_menu_path = path
	parent.actions.visible = true
	parent.save_confirm.visible = false
	parent.delete_confirm.visible = false
	if _only_load: 
		if not empty:
			parent.load_button.visible = true
		else:
			parent.load_button.visible = false
	elif empty:
		parent.save_button.visible = true
		parent.remove_button.visible = false
		parent.load_button.visible = false
	else:
		parent.save_button.visible = true
		parent.remove_button.visible = true
		parent.load_button.visible = true


func reset():
	# Seteamos el estado como no seleccionado
	_selected = false
	# Ajustamos la transparencia
	modulate.a8=255
