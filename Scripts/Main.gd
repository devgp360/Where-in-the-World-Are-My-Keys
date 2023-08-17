extends Node2D

#Definición del nodo Canvas
@onready var canvas_layer = $CanvasLayer
#Definición del nodo Principal
@onready var main = $CanvasLayer/Main
#Definición del nodo Guardar/Cargar
@onready var load = $CanvasLayer/Load
#Definición del nodo Sobre el juego
@onready var about = $CanvasLayer/About
#Definición del nodo Sonidos
@onready var sounds = $CanvasLayer/Sounds
#Definición del nodo Boton Continuar
@onready var _continue = $CanvasLayer/Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Continue
#Definición del Audioplayer
@onready var sound = $AudioStreamPlayer2D
#Definición del boton Guardar
@onready var saveButton = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions/SaveGame
#Definición del boton Borrar
@onready var removeBotton = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions/RemoveGame
#Definición del contenedor de acciones 
@onready var actions = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Actions
#Definición del contenedor de Confirmación de eliminación
@onready var removeConfirmation = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/RemoveConfirmation
#Definición del contenedor de Confirmación de sobreescribir
@onready var overwriteConfirmation = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/OverwriteConfirmation
#Definición del grid para guardar/cargar avances
@onready var inventoryCanvas = $CanvasLayer/Load/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/InventoryCanvas

#Variable para guardar el screenshot
var img: Image

# Función que se llama cuando la escena esta cargada
func _ready():
	#Asignamos el estado del juego
	var paused = get_tree().paused
	#Validamos si esta en pausa
	if (!paused):
		#Si el juego no esta en pausa escondemos el boton continuar
		_continue.visible = false 

# Función que siempre se llama
func _process(delta):
	pass
	
#Redirección al mapa principal	
func _on_map_pressed():
	#Cerrar la capa del menu
	canvas_layer.visible = false
	#Despausar el juego
	get_tree().paused = false
	#Cambiar la eacena
	get_tree().change_scene_to_file("res://Map.tscn")	

#Redirección a la sección de guardar/cargar avances
func _on_load_pressed():
	#No mostrar las opciones que no se eligieron
	main.visible = false
	about.visible = false
	sounds.visible = false	
	#Habilitar la opcion seleccionada
	load.visible = true
	#seteamos los estatuses de botones
	set_buttons()

#Redirección a la sección sobre el juego
func _on_about_pressed():
	#No mostrar las opciones que no se eligieron
	main.visible = false
	sounds.visible = false
	load.visible = false
	#Habilitar la opcion seleccionada
	about.visible = true

#Redirección a la sección sonidos
func _on_sounds_pressed():
	#No mostrar las opciones que no se eligieron
	main.visible = false
	about.visible = false
	load.visible = false
	#Habilitar la opcion seleccionada
	sounds.visible = true

#Salir del juego
func _on_quit_pressed():
	#Salimos del juego
	get_tree().quit()

#Regresar al menu principal
func _on_back_pressed():
	#No mostrar las opciones que no se eligieron
	about.visible = false
	load.visible = false
	sounds.visible = false
	#Habilitar la opcion seleccionada
	main.visible = true

#Acción para el boton continuar
func _on_continue_pressed():
	#No mostrar las opciones que no se eligieron
	about.visible = false
	load.visible = false
	sounds.visible = false
	main.visible = false
	#Pausamos audios
	sound.stop()
	#Reanudamos el juego
	get_tree().paused = false
	#Cerramos el menu
	canvas_layer.visible = false

#Inicialización de botones de acción
func set_buttons():
	#Resetamos la variable global de la celda activa
	Global.activeItemMenuId = ''
	#Creamos la lista de escenas donde no se debe aparecer el boton guardar
	var scenes = ["Map"]
	#Obtenemos el nombre de la escena actual
	var actual_scene = get_tree().get_current_scene().name
	#Validamos si la escena se encuentra en la lista de escepciones
	if (scenes.find(actual_scene,0) > -1):
		#escondemos el boton
		saveButton.visible = false

#Cuando precionamos el boton eliminar
func _on_remove_pressed():
	#Escondemos acciones
	actions.visible = false
	#Mostarmos confirmación
	removeConfirmation.visible = true

#Cuando confirmamos la eliminación
func _on_yes_remove_pressed():
	#Eliminamos el registro guardado
	SaveProgress.remove(Global.activeItemMenuId)
	#Recargamos el grid de celdas de avances
	inventoryCanvas.init()
	#Escondemos confirmación
	removeConfirmation.visible = false

#Cuando no se confirma la eliminación de avance
func _on_no_remove_pressed():
	#Mostarmos acciones
	actions.visible = true
	#Escondemos confirmación
	removeConfirmation.visible = false

#Cuando se confirma la acción de sobreescribir el avance
func _on_yes_overwrite_pressed():
	#Obtenemos el dato a guardar
	var data = get_tree().get_current_scene().get_save_data()
	#Sobreescribimos el progreso
	SaveProgress.overwrite(Global.activeItemMenuId, data, img)
	#Recargamos el grid de celdas de avances
	inventoryCanvas.init()
	#Escondemos confirmación
	overwriteConfirmation.visible = false

#Cuando no rechazamos la acción sobreescribir
func _on_no_overwrite_pressed():
	#Mostarmos acciones
	actions.visible = true
	#Escondemos confirmación
	overwriteConfirmation.visible = false

#Cuando guardamos el avance del juego
func _on_save_pressed():
	#Escondemos acciones
	actions.visible = false
	#Validamos si ya seleccionamos una celda
	if Global.activeItemMenuId:
		#Mostarmos confirmación
		overwriteConfirmation.visible = true
	else:
		#Obtenemos datos a guardar
		var data = get_tree().get_current_scene().get_save_data()
		#guardamos el progreso
		SaveProgress.save_game(data, img)
		#Recargamos el grid de celdas de avances
		inventoryCanvas.init()
		#Mostarmos acciones
		actions.visible = true
		#Escondemos confirmación
		removeConfirmation.visible = false
		
#Cuando cargamos el avance del juego
func _on_load_game_pressed():
		#Validamos si existe la ruta de la escena
	if (Global.itemMenuPath):
		#Quitamos la pausa
		get_tree().paused = false
		#Cambio de escena
		SceneTransition.change_scene(Global.itemMenuPath)
		
