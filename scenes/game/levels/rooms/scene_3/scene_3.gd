extends Node2D
## Clase que controla la escena 3
##
## Lee el progreso de la escena, escucha si se presiona pausa, prepara los datos de la escena a guardar

# DOCUMENTACIÓN SOBRE CREAR UNA NUEVA ESCENA: https://docs.google.com/document/d/1Tvp7PKcC4kSUtQO9wKEksT_cbA4rBEMZQ-artBsu5N4
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN MANEJO DE "NODOS" EN CAPAS CON YSORT: https://docs.google.com/document/d/1LEKG9qijIEIauFaB1zmUWPgTShxkI0whVbC3ngZrJ4E
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E
# DOCUMENTACIÓN (creación de escena): https://docs.google.com/document/d/1Tvp7PKcC4kSUtQO9wKEksT_cbA4rBEMZQ-artBsu5N4/edit?usp=drive_link

# Definición del nodo de menu
@export var pause_menu: PackedScene

# Declaramos la variable de datos de la escena
var _level_data = {}

# Definición del nodo main character
@onready var character = $MainCharacter
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función que se llama cuando la escena esta cargada
func _ready():
	# Cargamos datos guardados del juego
	_level_data = SaveProgress.get_saved_data(Global.active_item_menu_id)
	# Validamos si existe data
	if _level_data:
		#Seteamos datos iniciales
		_set_level_data(_level_data)
	# Buscar el nodo que contiene los objetos a recolectar, y se valida si ya está en el inventario
	# Si ya está en el inventario, se ocultará el elemento
	var collect = self.find_child("Collect")
	# Validamos si existen objetos
	if collect:
		# Obtenemos los nombres de objetos
		var item_list = InventoryCanvas.get_item_list_names()
		# Recorremos cada objeto
		for c in collect.get_children():
			# Obtenemos el nombre del objeto
			var _name = c.get_path_name()
			# Validamos si el nombre existe en la lista de objetos de la escena
			if item_list.find(_name) >= 0:
				# Ocultamos el objeto
				c.visible = false


# Función que siempre se llama
func _process(_delta):
	# Levantamos el menú principal
	if(Input.is_action_pressed("ui_cancel")):
		# Pausamos el juego
		get_tree().paused = true
		# Obtenemos el nodo de menú principal
		var pause: Node = pause_menu.instantiate()
		# Creamos Screenshot
		pause.img = get_viewport().get_texture().get_image()
		# Mostramos el menú
		get_tree().current_scene.add_child(pause)


# Cuando entramos a una area predeterminada
func _on_area_2d_area_entered(_area):
	pass #No hacemos nada, salimos


# Seteamos los datos de la escena
func _set_level_data(level_data: Dictionary):
	# Limpiamos el inventario
	InventoryCanvas.remove_all_items()
	# Seteamos datos del personaje principal
	_set_character_data(level_data.character)
	# Seteamos datos del inventario
	_set_inventory_data(level_data)


# Seteamos datos del personaje principal
func _set_character_data(characterData: Dictionary):
	# Ponemos al personaje en su posición guardada
	character.position = characterData.position
	# Seteamos datos del inventario
	for item in characterData.dressed:
		character.dress_item(item, true)


# Seteamos datos de inventario
func _set_inventory_data(level_data: Dictionary):
	# Obtenemos los objetos coleccionables
	var children = self.get_node("Collect").get_children()
	# Recorremos datos guardados
	for item_saved in level_data.inventory.items:
		# Agregamos objeto al inventario
		InventoryCanvas.add_item_by_name(item_saved.item)
		# Recorremos objetos coleccionables
		for item in children:
			if item.item_path_name == item_saved.item:
				# Escondemos el objeto
				item.visible = false


# DOCUMENTACIÓN (transición de escena): https://docs.google.com/document/d/1FciThS6B4qQEBely2iCMDfkRZIzwSrZLCo2Fu8nE5LQ/edit?usp=drive_link
# Cuando entramos a una area predeterminada
func _on_area_to_scena_2_area_entered(_area):
	# Pasamos a la escena 2
	SceneTransition.change_scene("res://scenes/game/levels/rooms/scene_2/scene_2.tscn")


# Obtenemos datos de la escena
func get_save_data():
	var time = Time.get_datetime_dict_from_system()
	# Declaramos la variable de objetos colleccionables
	var items = []
	# Obtenemos elementos del inventario disponible
	var item_list = InventoryCanvas.get_item_list_names()
	# Recorremos objetos colleccionables
	for item in item_list:
		# Agregamos el objeto a datos a guardar
		items.append({
			"item": item,
		})
		
	# Retornamos datos
	return {
		"id": "%02d-%02d-%02d %02d:%02d:%02d" % [
			time.day,
			time.month,
			time.year,
			time.hour,
			time.minute,
			time.second,
		],
		"name":"Scene3",
		"path": "res://scenes/game/levels/rooms/scene_3/scene_3.tscn",
		"inventory": {
			"items": items,
		},
		"character":{
			"position": character.position,
			"dressed": character.get_dress_item_list(),
		}
	}
