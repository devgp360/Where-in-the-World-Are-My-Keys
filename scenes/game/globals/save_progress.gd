extends Node
## Clase que controla guardado de avance de juego
##
## Guarda / Carga / Sobreescribe / Elimina avances de juego, revisa la existencia de carpeta de avances


# DOCUMENTACIÓN GUARDAR Y CARGAR EL AVANCE EN EL JUEGO: https://docs.google.com/document/d/1-mXoGmFTUdLby_V4wx4xU_idy6a0RdYuHLagJxLGakw

# Ruta para guardar los avances
const SAVE_GAME_PATH := "user://save.dat"
# Ruta para guardar los screens de escenas
const SAVE_SCREENS_FOLDER := "screens/"
# Ruta de carpeta para guardar los screens de escenas
const SAVE_SCREENS_PATH := "user://" + SAVE_SCREENS_FOLDER


# Inicialización de objeto inicial a guardar
func _init_object():
	# Inicializamos objeto vacío
	return {
		"point": [],
		"sound":{
			"music": 1,
			"main_character": 1,
			"npc": 1
		},
		'activeScene': ["Panajachel"],
		"items": []
	}


# Agregamos datos de escenas
func _add_scene(data_to_save: Dictionary, data: FileAccess):
	# Inicializamos objeto vacío
	var _data = _init_object()
	# Validamos si data no viene vacia
	if (data):
		# Leemos datos guardados
		_data = data.get_var(true)
		# Agregamos la escena
		_data.point.append(data_to_save)
	else:
		# Agregamos la escena
		_data.point.append(data_to_save)
	# Retornamos datos a guardar
	return _data


# Agregamos datos de sonidos
func _add_sounds(_name: String, vol: float, data: FileAccess):
	# Inicializamos objeto vacío
	var _data = _init_object()
	# Validamos si data no viene vacia
	if (data):
		_data = data.get_var(true)
		# Agregamos la configuración de sonidos
		_data.sound[_name] = vol
		# Retornamos datos a guardar
	else:
		# Agregamos la configuración de sonidos
		_data.sound[_name] = vol
	# Retornamos datos a guardar
	return _data


# Agregamos datos de la escena activa
func _add_active_scene(scene: String, data: FileAccess):
	# Inicializamos objeto vacío
	var _data = _init_object()
	# Validamos si data no viene vacia
	if (data):
		# Leemos datos guardados
		_data = data.get_var(true)
		# Validamos si hay escenas guardadas
		if (_data.activeScene.size()):
			# Bandera de validacion si la escena ya existe
			var exist = false
			# Recorremos escenas disponibles
			for i in range(_data.activeScene.size()):
				# Validamos si la escena ya esta guardada
				if(_data.activeScene[i] == scene):
					# Seteamos la bandera como ya existe la escena
					exist = true
			# Validamos si la escena no existe
			if not exist:
				# Agregamos la escena
				_data.activeScene.append(scene)
		else:
			# Agregamos la escena
			_data.activeScene.append(scene)
	else:
		# Agregamos la escena
		_data.activeScene.append(scene)
	# Retornamos datos a guardar
	return _data


# Eliminamos la escena guardada
func _remove_saved(id: String, data: FileAccess):
	# Validamos si data no viene vacia
	if (data):
		# Leemos datos guardados
		var _data = data.get_var(true)
		# Validamos si hay escenas guardadas
		if (_data.point.size()):
			var new_data = _data.point
			# Recorremos registros guardados
			for i in range(_data.point.size()):
				# Validamos si la escena es la que debemos eliminar
				if(_data.point[i-1].id == id):
					# Eliminamos la escena
					new_data.erase(_data.point[i-1])
			_data.point = new_data
			return _data
		else:
			# Retornamos 
			return _data
	else:
		# Retornamos 
		return data


# Sobreescribimos escenas guardadas
func _overwrite_saved(id: String, data_to_save: Dictionary, data: FileAccess, img: Image):
	# Validamos si data no viene vacia
	if (data):
		# Leemos datos guardados
		var _data = data.get_var(true)
		# Validamos si hay escenas guardadas
		if (_data.point.size()):
			var new_data = _data.point
			# Recorremos registros guardados
			for i in range(_data.point.size()):
				# Validamos si la escena es la que debemos eliminar
				if(_data.point[i].id == id):
					# Eliminamos la escena
					new_data[i] = data_to_save
			_data.point = new_data
			return _data
		else:
			# Retornamos 
			return _data
	else:
		# Retornamos 
		save_game(data_to_save, img)


# Guardamos el avance del juego
func _save_data(data: Dictionary) -> void:
	# Inicializamos el archivo para guardar datos
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	# Guardamos datos
	file.store_var(data,true)
	#  Cerramos el acrivo
	file.close()


# Buscamos los datos de la escena
func _find_scene_data(scene_id: String, data: Dictionary):
	# Validamos si datos existen
	if (data):
		# Parseamos datos
		var data_to_return = {}
		for d in data.point:
			if (d.id == scene_id):
				data_to_return = d
		# Retornamos datos guardados
		return data_to_return
	# Cerramos el archivo
	return null


# Validamos si no esxiste la carpeta, creamos la carpeta
func _validate_dir():
	# Tratamos de acceder a la carpeta
	var dir = DirAccess.open("user://")
	# Validamos si existe la carpeta
	if not dir.dir_exists(SAVE_SCREENS_FOLDER):
		# Creamos la carpeta si no existe
		dir.make_dir(SAVE_SCREENS_FOLDER)


# Guardamos el screenshot
func _save_screen(id: String, img: Image):
	# Validamos si existe carpeta para screens
	_validate_dir()
	# Guardamos imagen.
	var path = SAVE_SCREENS_PATH + (id + ".jpg").replace(" ", "_").replace(":", "_")
	# Guardamos el scrreenshot
	img.save_jpg(path)


# Eliminamos el screenshot
func _remove_screenshort(id: String):
	# Creamos la ruta de la imagen
	var path = SAVE_SCREENS_FOLDER + (id + ".jpg").replace(" ", "_").replace(":", "_")
	# Accedemos a la carpeta de datos de usuario
	var dir = DirAccess.open("user://")
	# Validamos si existe la imagen a eliminar
	if dir.file_exists(path):
		# Eliminamos la imagen
		dir.remove(path)


# Cargamos el avance guardado
func load_game():
	# Validamos si el archivo existe
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		return # No existe el archivo salimos
	# Inicializamos el archivo
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Validamos si datos existen
	if (file):
		# Parseamos datos
		var data = file.get_var(true)
		# Cerramos el archivo
		file.close()
		# Retornamos datos guardados
		return data
	#  Cerramos el acrivo
	file.close()
	# Retornamos
	return null


# Obtenemos el avance de luz
func get_saved_data(scene_id: String):
	# Validamos si el archivo existe
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		return # No existe el archivo salimos
	# Inicializamos el archivo
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Validamos si datos existen
	if (file):
		# Parseamos datos
		var data = file.get_var(true)
		# Cerramos el archivo
		file.close()
		# Retornamos datos guardados
		return _find_scene_data(scene_id, data)
	#  Cerramos el acrivo
	file.close()
	# Retornamos
	return null


# Guardamos los datos de la escena activa
func save_active_scene(_name: String) -> void:
	# Leemos el archivo donde se guardan los datos
	var data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Agregamos datos de la escena al objeto de datos
	data = _add_active_scene(_name,data)
	# Guardamos
	_save_data(data)


# Guardamos el el nivel de sonidos
func save_sounds(_name: String, vol: float) -> void:
	# Leemos el archivo donde se guardan los datos
	var data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Agregamos datos de la escena al objeto de datos
	data = _add_sounds(_name,vol,data)
	# Guardamos
	_save_data(data)


# Eliminamos el avance
func remove(id: String) -> void:
	# Eliminamos el archivo de screenshot
	_remove_screenshort(id)
	# Leemos el archivo donde se guardan los datos
	var data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Eliminamos el guardado eligido
	data = _remove_saved(id, data)
	# Guardamos
	_save_data(data)


# Sobreescribimos el avance
func overwrite(id: String, data_to_save: Dictionary, img: Image) -> void:
	# Eliminamos el archivo de screenshot
	_remove_screenshort(id)
	# Guardamos el screen nuevo
	_save_screen(data_to_save.id, img)	
	# Leemos el archivo donde se guardan los datos
	var data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Eliminamos el guardado eligido
	data = _overwrite_saved(id, data_to_save, data, img)
	# Guardamos
	_save_data(data)


# Guardamos el avance
func save_game(data_to_save: Dictionary, img: Image) -> void:
	# Preparamos datos a guardar
	_save_screen(data_to_save.id, img)
	# Leemos el archivo donde se guardan los datos
	var data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# Agregamos datos de la escena al objeto de datos
	data = _add_scene(data_to_save,data)
	# Guardamos
	_save_data(data)


# Seteamos los datos de la escena
func set_level_data(character: CharacterBody2D):
	# Cargamos datos guardados del juego
	var level_data = get_saved_data(Global.active_item_menu_id)
	# Validamos si existe data
	if not level_data:
		return 
	# Limpiamos el inventario
	InventoryCanvas.remove_all_items()
	# Seteamos datos del personaje principal
	_set_character_data(character, level_data.character)
	# Seteamos datos del inventario
	_set_inventory_data(level_data)


# Seteamos datos del personaje principal
func _set_character_data(character: CharacterBody2D, character_data: Dictionary):
	# Ponemos al personaje en su posición guardada
	character.position = character_data.position
	# Seteamos datos del inventario
	for item in character_data.dressed:
		# ponemos el objeto al personaje principal
		character.dress_item(item, true)


# Seteamos datos de inventario
func _set_inventory_data(level_data: Dictionary):
	# Obtenemos los objetos coleccionables
	var collect = self.get_node("Collect")
	if not collect:
		return
	# Obtenemos los objetos coleccionables
	var children = collect.get_children()
	# Recorremos datos guardados
	for item_saved in level_data.inventory.items:
		# Agregamos objeto al inventario
		InventoryCanvas.add_item_by_name(item_saved.item)
		# Recorremos objetos coleccionables
		for item in children:
			if item.item_path_name == item_saved.item:
				# Escondemos el objeto
				item.visible = false


# Obtenemos datos de la escena
func generate_save_data(character: CharacterBody2D, scene_name: String, scene_path: String):
	# Obtenemos la fecha y hora actuales
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
		"name": scene_name,
		"path": scene_path,
		"inventory": {
			"items": items,
		},
		"character":{
			"position": character.position,
			"dressed": character.get_dress_item_list(),
		},
	}

