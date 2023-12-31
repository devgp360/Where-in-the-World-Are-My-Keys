extends Node2D
## Clase de Inventario 
## 
## Renderización de celdas y objetos de inventario, funcionalidades de agregar nuevos objetos y remover los objetos de inventario ## Revisión de objetos puestos en personaje principal


# DOCUMENTACIÓN (catálogo de objetos): https://docs.google.com/document/d/1aFTTLLd4Yb8T_ntjjGlv4LHEGgnz8exqdcbFO9XK3MA/edit?usp=drive_link

# Referencia a todas las "cajas", que contienen objetos
var _item_contents = []
# Referencia de todos los nombres de objetos que hay en el inventario
var _item_object_names = []
# Referencia de los items
var _item_objects = []
# Referencia de items que está usando (vistiendo) el personaje
var _dressed_item_list = []
# "Objeto" seleccionado
var _current_item_selected = null
# Nombre del objeto seleccionado
var _current_item_name_selected = ""

@onready var canvas = $CanvasLayer # Canvas principal
@onready var animation_player = $CanvasLayer/AnimationPlayer # Player
@onready var grid = $CanvasLayer/TextureRect/GridContainer # Grid al cual se añaden elementos
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	# Cada "item" recolectado, se agregará dentro de un "contendor"
	# Este contenedor es un "sprite" que tiene una imagen con un "borde" simulando un marco
	# Dentro de este "marco" es donde se agregarán los "items"
	# Para evitar agregar todos los nodos manualmente (24 nodos en este caso), se hizo un ciclo
	#  que los agregará dinámicamente.
	for n in 24:
		var item = load("res://scenes/game/inventory/item_content/item_content.tscn").instantiate()
		grid.add_child(item) # Agregamos el nodo "marco" a un grid
		_item_contents.append(item) # Guardamos la referencia del nodo "marco" en un array


# Función que se ejecuta en cada frame
func _process(_delta):
	_process_item_selected()


# Función para detectar eventos del teclado o ratón
func _unhandled_input(event):
	# Definimos escenas donde no debe aparecer el inventario
	var scenes = ["Splash", "Map", "MainMenu"]
	# Obtenemos el nombre de la escena actual
	var actual_scene = get_tree().get_current_scene().name
	# Si estamos en las escenas definidas no mostramos Inventario
	if scenes.find(actual_scene,0) > -1:
		return
	if event.is_action_pressed("wheel_up"):
		# Cuando deslizamos la rueda del ratón hacia arriba, ocultamos el inventario
		animation_player.play_backwards("down")
		await animation_player.animation_finished
		canvas.visible = false
	elif event.is_action_pressed("wheel_down"):
		# Cuando deslizamos la rueda del ratón hacia abajo, mostramos el inventario
		if canvas.visible == true:
			return
		canvas.visible = true
		animation_player.play("down")
		await animation_player.animation_finished


# Función "clic" para cada elemento del inventario
func _pressed(_name: String):
	# Cargamos el nodo principal de la escena. Si no existe, se termina la función
	var escena1 = get_tree().get_root().get_node("Main")
	if not escena1:
		return
		
	# Funcionalidad para "quitarse/ponerse" los lentes al dar clic en el item desde el inventario
	if _name == 'collect/item_lentes':
		var glasses_name = "Glasses";
		var character = escena1.find_child("MainCharacter")
		var index = _dressed_item_list.find(glasses_name)
		if index >= 0:
			character.dress_item(glasses_name, false)
			_dressed_item_list.remove_at(index)
		else:
			character.dress_item(glasses_name, true)
			_dressed_item_list.append(glasses_name)


# DOCUMENTACIÓN (gestión de memoria): https://docs.google.com/document/d/1diS6YOpBhLUTI9tk7YTZcH5Ha64bXg9u-PVhBXfOEz4/edit#heading=h.e2j6ax5ma83s
# Función que añade un item al inventario
# Añadir significa, cargar un elemento (escena) y agregarlo al grid
# El nombre del item, tiene que existir como una escena
func add_item_by_name(_name: String, params = null):
	# Si el item ya existe (ya está agregado), se termina la función
	var index = _item_object_names.find(_name)
	if index >= 0:
		return
	
	# Cargamos el recurso
	var item_to_load = load("res://scenes/game/inventory/items/" + _name + ".tscn")
	
	# Si no existe el recurso, se termina la función
	if not item_to_load:
		return
	
	# Agregamos el item al grid, y guardamos las referencias (para poder eliminarlo si es requerido)
	index = _item_object_names.size()
	var item = item_to_load.instantiate()
	var item_content = _item_contents[index]
	item_content.add_child(item)
	_item_object_names.append(_name);
	_item_objects.append(item)
	item.pressed.connect(_pressed.bind(_name))
	# Algunos objetos, pueden tener un método para agregarle parámetros
	if item.has_method("add_params") and params:
		item.add_params(_name, params) # Pasamos parámetros cuando creamos el objeto


# DOCUMENTACIÓN (gestión de memoria): https://docs.google.com/document/d/1diS6YOpBhLUTI9tk7YTZcH5Ha64bXg9u-PVhBXfOEz4/edit#heading=h.e2j6ax5ma83s
# Se elimina un elemento del iventario
# Eliminar significa, buscar el "nodo" y eliminarlo del grid principal
# Al eliminar el nodo, todos los demás nodos posteriores, se moverán "hacia atrás"
# para evitar dejar "espacios vacíos"
func _remove_item_by_name(_name: String):
	var index = _item_object_names.find(_name)
	if index >= 0:
		var item_content = _item_contents[index] # Nodo que es un "cuadro" contenedor del item recolectado
		var item = _item_objects[index] # Nodo que tiene el item recolectado
		
		# Removemos el nodo del item
		item_content.remove_child(item)
		item.queue_free(); # Liberamos memoria (porque no lo vamos a volver a usar)
		
		# Movemos todos los items "hacia atrás" para que ocupen el espacio vacío
		var size = _item_objects.size()
		for n in range(index, size - 1):
			var current_content = _item_contents[n]
			var next_content = _item_contents[n + 1]
			var next_item = _item_objects[n + 1];
			# Removemos el item "next_item" (pero no liberamos memoria)
			next_content.remove_child(next_item);
			# El item removido anteriormente, se reutiliza (agrega) en otro nodo
			current_content.add_child(next_item);
		
		# Quitamos el nombre del listado de "nombres de items"
		_item_object_names.remove_at(index)
		
		# Quitamos el nodo, del listado de nodos tipo item
		_item_objects.remove_at(index)


# Elimina todos los elementos del inventario
func remove_all_items():
	var size = _item_object_names.size()
	for i in size:
		_remove_item_by_name(_item_object_names[size - i - 1])


# Retorna un listado de "nombres" de items que están en inventario
func get_item_list_names():
	return _item_object_names


# Retorna un listado de "nombres" de items que el personaje debe "vestir"
func get_dressed_item_list():
	return _dressed_item_list


# Devuelve "true", si un item está siendo "vestido" por el personaje principal
func is_wearing(_name: String):
	return _dressed_item_list.find(_name) >= 0


# Función que servirá para seleccionar un item a usar (sobre otro item)
func select_item_to_use(_name: String, select: bool):
	# Quitar el item seleccionado
	if not select and _current_item_selected:
		_remove_selected_item()
	# Si ya está seleccionado el item, solo terminamos la función
	if _current_item_name_selected == _name:
		return
	# Cargamos el nuevo item
	var item_to_load = load("res://scenes/game/inventory/items/" + _name + ".tscn")
	if not item_to_load: # Si no existe el recurso, se termina la función
		return
	var escena = get_tree().get_root().get_node("Main")
	if escena:
		_remove_selected_item() # Removemos cualquier item que pueda existir previamente
		var item = item_to_load.instantiate()
		var index = _item_object_names.find(_name)
		var params = null
		if _item_objects[index].has_method("get_params"):
			params = _item_objects[index].get_params()
		# Se deberá agregar el item a la escena (luego moverlo junto al mouse)
		# - Falta implementación
		escena.add_child(item)
		_current_item_selected = item
		_current_item_name_selected = _name
		# Agregamos los parámetros del item (si tiene)
		if item.has_method("add_params") and params:
			item.add_params(_name, params)
		if item.has_method("set_item_selected"):
			item.set_item_selected()


# Se remueve "la selección" de un item de inventario
func _remove_selected_item():
	if _current_item_selected:
		var escena = get_tree().get_root().get_node("Main")
		if escena:
			escena.remove_child(_current_item_selected)
		_current_item_selected.queue_free() # Liberamos la memoria
		_current_item_selected = null
		_current_item_name_selected = ""


# Procesamos un item seleccionado
# Consiste en mostrar el objeto (junto al puntero del ratón) y moverlo en las mismas coordenadas
func _process_item_selected():
	if not _current_item_selected:
		return
	# Falta implementar la funcionalidad de mover objeto junto al puntero
	_current_item_selected.position = get_global_mouse_position()


# Retorna el nombre del objeto actualmente seleccionado
func get_current_item_name_selected():
	return _current_item_name_selected
