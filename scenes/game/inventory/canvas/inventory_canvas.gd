extends Node2D
## Clase de Inventario 
## 
## Renderización de celdas y objetos de inventario, funcionalidades de agregar nuevos objetos y remover los objetos de inventario ## Revisión de objetos puestos en personaje principal


# DOCUMENTACIÓN (catálogo de objetos): https://docs.google.com/document/d/1aFTTLLd4Yb8T_ntjjGlv4LHEGgnz8exqdcbFO9XK3MA/edit?usp=drive_link

# Referencia a todas las "cajas", que contienen objetos
var item_contents = []
# Referencia de todos los nombres de objetos que hay en el inventario
var item_object_names = []
# Referencia de los items
var item_objects = []
# Referencia de items que está usando (vistiendo) el personaje
var dressed_item_list = []
# "Objeto" seleccionado
var current_item_selected = null
# Nombre del objeto seleccionado
var current_item_name_selected = ""

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
		item_contents.append(item) # Guardamos la referencia del nodo "marco" en un array


# Función que se ejecuta en cada frame
func _process(_delta):
	process_item_selected()


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
	check_press_item_puzzle_jardin(_name) # Validar clic en items de puzzle "Jardín"
	# Cargamos el nodo principal de la escena. Si no existe, se termina la función
	var escena1 = get_tree().get_root().get_node("Main")
	if not escena1:
		return
		
	# Funcionalidad para "quitarse/ponerse" los lentes al dar clic en el item desde el inventario
	if _name == 'puzzle_vidriera/item_lentes':
		var character = escena1.find_child("MainCharacter")
		var index = dressed_item_list.find("glasses")
		if index >= 0:
			character.dress_item("glasses", false)
			dressed_item_list.remove_at(index)
		else:
			character.dress_item("glasses", true)
			dressed_item_list.append("glasses")


# DOCUMENTACIÓN (gestión de memoria): https://docs.google.com/document/d/1diS6YOpBhLUTI9tk7YTZcH5Ha64bXg9u-PVhBXfOEz4/edit#heading=h.e2j6ax5ma83s
# Función que añade un item al inventario
# Añadir significa, cargar un elemento (escena) y agregarlo al grid
# El nombre del item, tiene que existir como una escena
func add_item_by_name(_name: String, params = null):
	# Si el item ya existe (ya está agregado), se termina la función
	var index = item_object_names.find(_name)
	if index >= 0:
		return
	
	# Cargamos el recurso
	var item_to_load = load("res://scenes/game/inventory/items/" + _name + ".tscn")
	
	# Si no existe el recurso, se termina la función
	if not item_to_load:
		return
	
	# Agregamos el item al grid, y guardamos las referencias (para poder eliminarlo si es requerido)
	index = item_object_names.size()
	var item = item_to_load.instantiate()
	var item_content = item_contents[index]
	item_content.add_child(item)
	item_object_names.append(_name);
	item_objects.append(item)
	item.pressed.connect(_pressed.bind(_name))
	# Algunos objetos, pueden tener un método para agregarle parámetros
	if item.has_method("add_params") and params:
		item.add_params(_name, params) # Pasamos parámetros cuando creamos el objeto


# DOCUMENTACIÓN (gestión de memoria): https://docs.google.com/document/d/1diS6YOpBhLUTI9tk7YTZcH5Ha64bXg9u-PVhBXfOEz4/edit#heading=h.e2j6ax5ma83s
# Se elimina un elemento del iventario
# Eliminar significa, buscar el "nodo" y eliminarlo del grid principal
# Al eliminar el nodo, todos los demás nodos posteriores, se moverán "hacia atrás"
# para evitar dejar "espacios vacíos"
func remove_item_by_name(_name: String):
	var index = item_object_names.find(_name)
	if index >= 0:
		var item_content = item_contents[index] # Nodo que es un "cuadro" contenedor del item recolectado
		var item = item_objects[index] # Nodo que tiene el item recolectado
		
		# Removemos el nodo del item
		item_content.remove_child(item)
		item.queue_free(); # Liberamos memoria (porque no lo vamos a volver a usar)
		
		# Movemos todos los items "hacia atrás" para que ocupen el espacio vacío
		var size = item_objects.size()
		for n in range(index, size - 1):
			var current_content = item_contents[n]
			var next_content = item_contents[n + 1]
			var next_item = item_objects[n + 1];
			# Removemos el item "next_item" (pero no liberamos memoria)
			next_content.remove_child(next_item);
			# El item removido anteriormente, se reutiliza (agrega) en otro nodo
			current_content.add_child(next_item);
		
		# Quitamos el nombre del listado de "nombres de items"
		item_object_names.remove_at(index)
		
		# Quitamos el nodo, del listado de nodos tipo item
		item_objects.remove_at(index)


# Elimina todos los elementos del inventario
func remove_all_items():
	var size = item_object_names.size()
	for i in size:
		remove_item_by_name(item_object_names[size - i - 1])


# Retorna un listado de "nombres" de items que están en inventario
func get_item_list_names():
	return item_object_names


# Retorna un listado de "nombres" de items que el personaje debe "vestir"
func get_dressed_item_list():
	return dressed_item_list


# Devuelve "true", si un item está siendo "vestido" por el personaje principal
func is_wearing(_name: String):
	return dressed_item_list.find(_name) >= 0


# Función especial para validar si se da clic en un item del puzzle de "Jardín"
func check_press_item_puzzle_jardin(_name: String):
	if not _name.begins_with("puzzle_jardin/"): # Si no es item de "jardín" terminamos la función
		return
	# Validamos que sea el iten de "brebaje"
	if _name.ends_with("/item_brebaje_1"):
		# Cargamos nodo principal (o se retorna de no existir)
		var escena1 = get_tree().get_root().get_node("Main")
		if not escena1:
			return
		# Se busca el personaje principal (o se retorna de no existir)
		var character = escena1.find_child("MainCharacter")
		if not character:
			return
		var params = null
		var index = item_object_names.find(_name)
		var item = item_objects[index]
		# Buscamos parámetros del item (si existen)
		if item.has_method("get_params"):
			params = item.get_params()
		# Cerramos el inventario (el canvas)
		animation_player.play_backwards("down")
		await animation_player.animation_finished
		canvas.visible = false
		# Al usar el "brebaje", lo eliminamos del inventario
		remove_item_by_name(_name)
		# Le "comunicamos" al personaje que use el item "clicado"
		character.use_item(_name, params)


# Función que servirá para seleccionar un item a usar (sobre otro item)
func select_item_to_use(_name: String, select: bool):
	# Quitar el item seleccionado
	if not select and current_item_selected:
		remove_selected_item()
	# Si ya está seleccionado el item, solo terminamos la función
	if current_item_name_selected == _name:
		return
	# Cargamos el nuevo item
	var item_to_load = load("res://scenes/game/inventory/items/" + _name + ".tscn")
	if not item_to_load: # Si no existe el recurso, se termina la función
		return
	var escena = get_tree().get_root().get_node("Main")
	if escena:
		remove_selected_item() # Removemos cualquier item que pueda existir previamente
		var item = item_to_load.instantiate()
		var index = item_object_names.find(_name)
		var params = null
		if item_objects[index].has_method("get_params"):
			params = item_objects[index].get_params()
		# Se deberá agregar el item a la escena (luego moverlo junto al mouse)
		# - Falta implementación
		escena.add_child(item)
		current_item_selected = item
		current_item_name_selected = _name
		# Agregamos los parámetros del item (si tiene)
		if item.has_method("add_params") and params:
			item.add_params(_name, params)
		if item.has_method("set_item_selected"):
			item.set_item_selected()


# Se remueve "la selección" de un item de inventario
func remove_selected_item():
	if current_item_selected:
		var escena = get_tree().get_root().get_node("Main")
		if escena:
			escena.remove_child(current_item_selected)
		current_item_selected.queue_free() # Liberamos la memoria
		current_item_selected = null
		current_item_name_selected = ""


# Procesamos un item seleccionado
# Consiste en mostrar el objeto (junto al puntero del ratón) y moverlo en las mismas coordenadas
func process_item_selected():
	if not current_item_selected:
		return
	# Falta implementar la funcionalidad de mover objeto junto al puntero
	current_item_selected.position = get_global_mouse_position()


# Retorna el nombre del objeto actualmente seleccionado
func get_current_item_name_selected():
	return current_item_name_selected
