extends Node2D
# DOCUMENTACIÓN SOBRE CREAR UNA NUEVA ESCENA: https://docs.google.com/document/d/1Tvp7PKcC4kSUtQO9wKEksT_cbA4rBEMZQ-artBsu5N4
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN MANEJO DE "NODOS" EN CAPAS CON YSORT: https://docs.google.com/document/d/1LEKG9qijIEIauFaB1zmUWPgTShxkI0whVbC3ngZrJ4E
# DOCUMENTACIÓN MANEJO DE AUDIOS: https://docs.google.com/document/d/1-RtHioFa9rFuJvsTv92m3UQGEuosRqYBV5CTjWOPg_E

#Definición del nodo de inventario
@onready var inventory:= $Inventory
#Definición del nodo de menu
@export var PauseMenu: PackedScene

#Definición del nodo main character
@onready var character = $MainCharacter

#Definición del nodo altar
@onready var altar = $PuzzleMaximon/AltarMaximon

#Definición del nodo door
@onready var door = $PuzzleMaximon/Door
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
	SaveProgress.save_active_scene("Antigua")

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

#Cuando entramos a una area predeterminada
func _on_area_2d_area_entered(area):
	#Redireccionamos a la escena 3
	SceneTransition.change_scene("res://Scene3.tscn")
	
func _on_area_to_scena_1_body_entered(body):
	#Redireccionamos a la escena 1
	SceneTransition.change_scene("res://Scene1.tscn")

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
	#Obtenemos la fecha y hora actuales
	var time = Time.get_datetime_dict_from_system()
	#Declaramos la variable de objetos colleccionables
	var items = []
	#Creamos la varianle de puzzles
	var riddles = []
	#Obtenemos elementos del inventario disponible
	var item_list = InventoryCanvas.get_item_list_names()
	#Recorremos objetos colleccionables
	for item in item_list:
		#Agregamos el objeto a datos a guardar
		items.append({
			"item": item,
		})
	#Preparamos los datos de puzzles
	var riddles_data = [altar,door]
	#Recorremos los objetos de puzzles
	for riddle in riddles_data:
		#Validamos si puzzle  esta activo
		if riddle.visible:
			#Agregamos objetos de puzzles a guardar
			riddles.append({
				"item": riddle.name,
			})
			
	#Retornamos datos
	return {
		"id": "%02d-%02d-%02d %02d:%02d:%02d" % [time.day, time.month, time.year, time.hour, time.minute, time.second],
		"name":"Scene2",
		"path": "res://Scene2.tscn",
		"riddles": riddles,
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
		character.dress_item(item, true)
		
#Seteamos datos de inventario
func set_inventory_data(level_data: Dictionary):
	#obtenemos los objetos colleccionables
	var children = self.get_node("Collect").get_children()		
	#Recorremos datos guardados
	for item_saved in level_data.inventory.items:
		#Agregamos objeto al inventario
		InventoryCanvas.add_item_by_name(item_saved.item)
		#Recorremos objetos colleccionables
		for item in children:
			if item.item_path_name == item_saved.item:
				#Escondemos el objeto
				item.visible = false
				
	#Recorremos Puzzles
	if (level_data.has('riddles')):
		#Recorremos los objetos de puzzles
		for riddle in level_data.riddles:
			#Validamos si el puzzle es de Maximon
			if riddle.item == "AltarMaximon":
				#Mostramos el Altar
				altar.visible = true
				#Encendemos animación
				altar.get_node("AnimationPlayer").play("show")
			#Validamos si el puzzle es de Puerta
			elif riddle.item == "Door": 
				#Mostramos la puerta
				door.visible = true
