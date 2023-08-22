extends Node2D
# DOCUMENTACIÓN SOBRE CREAR UNA NUEVA ESCENA: https://docs.google.com/document/d/1Tvp7PKcC4kSUtQO9wKEksT_cbA4rBEMZQ-artBsu5N4
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN MANEJO DE "NODOS" EN CAPAS CON YSORT: https://docs.google.com/document/d/1LEKG9qijIEIauFaB1zmUWPgTShxkI0whVbC3ngZrJ4E
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E
# DOCUMENTACIÓN (creación de escena): https://docs.google.com/document/d/1Tvp7PKcC4kSUtQO9wKEksT_cbA4rBEMZQ-artBsu5N4/edit?usp=drive_link

#Definición del nodo de menu
@export var PauseMenu: PackedScene
#Definición del nodo main character
@onready var character = $MainCharacter
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

#Declaramos la variable de datos de la escena
var level_data = {}

# Función que se llama cuando la escena esta cargada
func _ready():
	#Cargamos datos guardados del juego
	level_data = SaveProgress.get_saved_data(Global.activeItemMenuId)
	#Validamos si existe data
	if level_data:
		#Seteamos datos iniciales
		set_level_data(level_data)
	#Desbloqueamos la siguiente escena
	# DOCUMENTACIÓN (guardado de progreso): https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs/edit?usp=drive_link
	SaveProgress.save_active_scene("Tikal")
	
	# Buscar el nodo que contiene los objetos a recolectar, y se valida si ya está en el inventario
	# Si ya está en el inventario, se ocultará el elemento
	var collect = self.find_child("Collect")
	#Validamos si existen objetos
	if collect:
		#Obtenemos los nombres de objetos
		var item_list = InventoryCanvas.get_item_list_names()
		#recorremos cada objeto
		for c in collect.get_children():
			#Obtenemos el nombre del objeto
			var name = c.get_path_name()
			#Validamos si el nombre existe en la lista de objetos de la escena
			if item_list.find(name) >= 0:
				#ocultamos el objeto
				c.visible = false

# Función que siempre se llama
func _process(delta):
	#Levantamos el menú principal
	if(Input.is_action_pressed("ui_cancel")):
		#Pausamos el juego
		get_tree().paused = true
		var pause: Node = (PauseMenu).instantiate()
		#Creamos Screenshot
		pause.img = get_viewport().get_texture().get_image()
		#mostramos el menú
		get_tree().current_scene.add_child(pause)

# DOCUMENTACIÓN (transición de escena): https://docs.google.com/document/d/1FciThS6B4qQEBely2iCMDfkRZIzwSrZLCo2Fu8nE5LQ/edit?usp=drive_link
#Cuando entramos a una area predeterminada
func _on_area_2d_area_entered(area):
	#Cambio de escena
	SceneTransition.change_scene("res://Scene2.tscn")

#Seteamos los datos de la escena
func set_level_data(level_data: Dictionary):
	#Limpiamos el inventario
	InventoryCanvas.remove_all_items()
	#Seteamos datos del personaje principal
	set_character_data(level_data.character)
	#Seteamos datos del inventario
	set_inventory_data(level_data)

#Obtenemos datos de la escena
func get_save_data():
	#Obtenemos la fecha y el tiempo actual
	var time = Time.get_datetime_dict_from_system()
	#Declaramos la variable de objetos colleccionables
	var items = []
	#Obtenemos elementos del inventario disponible
	var item_list = InventoryCanvas.get_item_list_names()
	#recorremos los objetos
	for item in item_list:
		#Agregamos el objeto a datos a guardar
		items.append({
			"item": item,
		})
	#Retornamos datos
	return {
		"id": "%02d-%02d-%02d %02d:%02d:%02d" % [time.day, time.month, time.year, time.hour, time.minute, time.second],
		"name":"Scene1",
		"path": "res://Scene1.tscn",
		"inventory": {
			"items": items,
		},
		"character":{
			"position": character.position,
			"dressed": character.dress_item_list
		}
	}

#Seteamos datos del personaje principal
func set_character_data(characterData: Dictionary):
	#Ponemos al personaje en su posición guardada
	character.position = characterData.position
	#Seteamos datos del inventario
	for item in characterData.dressed:
		#ponemos el objeto al personaje principal
		character.dress_item(item, true)

#Seteamos datos de inventario
func set_inventory_data(level_data: Dictionary):
	#obtenemos los objetos coleccionables
	var children = self.get_node("Collect").get_children()		
	#Recorremos datos guardados
	for item_saved in level_data.inventory.items:
		#Agregamos objeto al inventario
		InventoryCanvas.add_item_by_name(item_saved.item)
		#Recorremos objetos coleccionables
		for item in children:
			if item.item_path_name == item_saved.item:
				#Escondemos el objeto
				item.visible = false
