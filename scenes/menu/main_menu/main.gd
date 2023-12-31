extends Node2D
## Clase que controla el menú principal
##
## Cambia las ventanas del menú, controla los botones del menú, guarda y carga el avance del juego


# DOCUMENTACIÓN SOBRE MENÚ PRINCIPAL: https://docs.google.com/document/d/1Y9rdN-w_cVtgCGX_8UTuPlDmlG2pUDOx_qZjrRhr2P4
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E
# DOCUMENTACIÓN GUARDAR Y CARGAR EL AVANCE EN EL JUEGO: https://docs.google.com/document/d/1-mXoGmFTUdLby_V4wx4xU_idy6a0RdYuHLagJxLGakw
# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

#Variable para guardar el screenshot
var img: Image

# Variable global, para controlar animación del fondo
var is_backwards = false # Cuando se hace la animación "de regreso" se activa a "true"

# Definición del nodo Canvas
@onready var canvas_layer = $CanvasLayer

# Definición del nodo Principal
@onready var main = $CanvasLayer/Main

# Definición del nodo Guardar/Cargar
@onready var loader = $CanvasLayer/Load

# Definición del nodo Sobre el juego
@onready var about = $CanvasLayer/About

# Definición del nodo Sonidos
@onready var sounds = $CanvasLayer/Sounds

# Definición del nodo Boton Continuar
@onready var _continue = $CanvasLayer/Main/Continue

# Definición del Audioplayer
@onready var sound = $AudioStreamPlayer2D

# Definición del node de animación
@onready var animation = $CanvasLayer/AnimationPlayer

# Definición del boton Guardar
@onready var save_button = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions/SaveGame

# Definición del boton Borrar
@onready var remove_botton = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions/RemoveGame

# Definición del contenedor de acciones 
@onready var actions = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions

# Definición del contenedor de Confirmación de eliminación
@onready var remove_confirmation = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/RemoveConfirmation

# Definición del contenedor de Confirmación de sobreescribir
@onready var overwrite_confirmation = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/OverwriteConfirmation

# Definición del grid para guardar/cargar avances
@onready var inventory_canvas = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/InventoryCanvas
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función que se llama cuando la escena esta cargada
func _ready():
	# Asignamos el estado del juego
	var _paused = get_tree().paused
	# Validamos si esta en pausa
	if not _paused:
		# Si el juego no esta en pausa escondemos el boton continuar
		_continue.visible = false
	# Iniciamos la animación del fondo
	animation.play("move_background")

# Redirección al mapa principal	
func _on_map_pressed():
	# Cerrar la capa del menu
	canvas_layer.visible = false
	# Despausar el juego
	get_tree().paused = false
	# Cambiar la eacena
	get_tree().change_scene_to_file("res://scenes/game/levels/rooms/map/map.tscn")


# Redirección a la sección de guardar/cargar avances
func _on_load_pressed():
	# No mostrar las opciones que no se eligieron
	main.visible = false
	about.visible = false
	sounds.visible = false	
	# Habilitar la opcion seleccionada
	loader.visible = true
	# Seteamos los estatuses de botones
	_set_buttons()


# Redirección a la sección sobre el juego
func _on_about_pressed():
	# No mostrar las opciones que no se eligieron
	main.visible = false
	sounds.visible = false
	loader.visible = false
	# Habilitar la opcion seleccionada
	about.visible = true


# Redirección a la sección sonidos
func _on_sounds_pressed():
	# No mostrar las opciones que no se eligieron
	main.visible = false
	about.visible = false
	loader.visible = false
	# Habilitar la opcion seleccionada
	sounds.visible = true


# Salir del juego
func _on_quit_pressed():
	# Salimos del juego
	get_tree().quit()


# Regresar al menu principal
func _on_back_pressed():
	# No mostrar las opciones que no se eligieron
	about.visible = false
	loader.visible = false
	sounds.visible = false
	# Habilitar la opcion seleccionada
	main.visible = true


# Acción para el boton continuar
func _on_continue_pressed():
	# No mostrar las opciones que no se eligieron
	about.visible = false
	loader.visible = false
	sounds.visible = false
	main.visible = false
	# Pausamos audios
	sound.stop()
	# Reanudamos el juego
	get_tree().paused = false
	# Cerramos el menu
	canvas_layer.visible = false


# Cuando precionamos el boton eliminar
func _on_remove_pressed():
	# Escondemos acciones
	actions.visible = false
	# Mostarmos confirmación
	remove_confirmation.visible = true


# Cuando confirmamos la eliminación
func _on_yes_remove_pressed():
	# Eliminamos el registro guardado
	SaveProgress.remove(Global.active_item_menu_id)
	# Recargamos el grid de celdas de avances
	inventory_canvas.init()
	# Escondemos confirmación
	remove_confirmation.visible = false


# Cuando no se confirma la eliminación de avance
func _on_no_remove_pressed():
	# Mostarmos acciones
	actions.visible = true
	# Escondemos confirmación
	remove_confirmation.visible = false


# Cuando se confirma la acción de sobreescribir el avance
func _on_yes_overwrite_pressed():
	# Obtenemos el dato a guardar
	var _data = get_tree().get_current_scene().get_save_data()
	# Sobreescribimos el progreso
	SaveProgress.overwrite(Global.active_item_menu_id, _data, img)
	# Recargamos el grid de celdas de avances
	inventory_canvas.init()
	# Escondemos confirmación
	overwrite_confirmation.visible = false


# Cuando no rechazamos la acción sobreescribir
func _on_no_overwrite_pressed():
	# Mostarmos acciones
	actions.visible = true
	# Escondemos confirmación
	overwrite_confirmation.visible = false


# Cuando guardamos el avance del juego
func _on_save_pressed():
	# Escondemos acciones
	actions.visible = false
	# Validamos si ya seleccionamos una celda
	if Global.active_item_menu_id:
		# Mostarmos confirmación
		overwrite_confirmation.visible = true
	else:
		# Obtenemos datos a guardar
		var _data = get_tree().get_current_scene().get_save_data()
		# Guardamos el progreso
		SaveProgress.save_game(_data, img)
		# Recargamos el grid de celdas de avances
		inventory_canvas.init()
		# Mostarmos acciones
		actions.visible = true
		# Escondemos confirmación
		remove_confirmation.visible = false


# Cuando cargamos el avance del juego
func _on_load_game_pressed():
		# Validamos si existe la ruta de la escena
	if Global.item_menu_path:
		# Quitamos la pausa
		get_tree().paused = false
		# Cambio de escena
		SceneTransition.change_scene(Global.item_menu_path)


# Inicialización de botones de acción
func _set_buttons():
	# Resetamos la variable global de la celda activa
	Global.active_item_menu_id = ''
	# Creamos la lista de escenas donde no se debe aparecer el boton guardar
	var _scenes = ["Map"]
	# Obtenemos el nombre de la escena actual
	var actual_scene = get_tree().get_current_scene().name
	# Validamos si la escena se encuentra en la lista de escepciones
	if _scenes.find(actual_scene,0) > -1:
		# Escondemos el boton
		save_button.visible = false


func _on_animation_player_animation_finished(anim_name):
	if is_backwards:
		animation.play("move_background")
		is_backwards = false
	else:
		animation.play_backwards("move_background")
		is_backwards = true
