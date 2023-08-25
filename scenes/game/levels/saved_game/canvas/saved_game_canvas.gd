extends Node2D
## Clase que guarda y lee el avance en el juego
##
## Crea las celdas para guardar el avance, prellena los puntos guardados, carga la escena guardada, limpia las celdas del listado de guardado

# DOCUMENTACIÓN GUARDAR Y CARGAR EL AVANCE EN EL JUEGO: https://docs.google.com/document/d/1-mXoGmFTUdLby_V4wx4xU_idy6a0RdYuHLagJxLGakw
# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

#Ruta de Screens guardados
const SAVE_SCREENS_PATH := "user://screens/"
#Enlazamos grid container
@onready var grid = $GridContainer
#Declaramos el boton Guardar
@export var actions : VBoxContainer
#Declaramos el boton Guardar
@export var saveButton : Button
#Declaramos el boton Guardar
@export var loadButton : Button
#Declaramos el boton Guardar
@export var removeButton : Button
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Referencia a todas las "cajas", que contienen objetos
var item_contents = []
# Referencia a todas las "cajas", que contienen objetos
var all_items = []
# Referencia de total de escenas disponibles
var totalItems = 6
#Configuracion del item por defecto
var lock = {"name":"lock","path":"", "id":""}

func _ready():
	#Limpiamos grid
	grid.reset_size()
	# Recorremos el total disponible de escenas
	for n in totalItems:
		#Cargamos el contenedor de escenas
		var item = load("res://SavedGame/item_content/item_content.tscn").instantiate()
		#Agregamos escena al grid
		grid.add_child(item)
		#Guardamos el item del grid
		item_contents.append(item)
	#Inicializamos la revision de datos guardados
	init()

func init():
	for item in all_items:
		#Reseteamos el estado
		if item != null:
			item.queue_free()

	#Cargamos datos guardados
	var data = SaveProgress.load_game()
	#Validamos si hay datos guardados
	if (data && data.point.size()):
		# Recorremos el total disponible de escenas
		for n in totalItems:
			#Si la escena guardada existe ponemos el screen de la escena
			if (data.point.size() > n && data.point[n]):
				#Ponemos el screen de la escena
				add_item_by_name(data.point[n],n)
			else:
				#Ponemos el screen de la escena no guardada
				add_item_by_name(lock,n,true)
	else:
		#Ponemos los screens de las escenas no guardadas
		fill_lock_img()
		
func fill_lock_img():
	# Recorremos el total disponible de escenas
	for n in totalItems:
		#Ponemos los screens de las escenas no guardadas
		add_item_by_name(lock,n,true)

func add_item_by_name(scene: Dictionary, index:int, empty=false):
	# Cargamos el recurso
	var item_to_load = load("res://SavedGame/item/Item.tscn")
	
	# Si no existe el recurso, se termina la función
	if not item_to_load:
		return
	#Seleccionamos el gred actual
	var item_content = item_contents[index]
	#Inicializamos el gred actual
	var item = item_to_load.instantiate()
	#Generamos el nombre de la imagen
	var _name = (scene.id + ".jpg").replace(" ", "_").replace(":", "_")
	#Obtenemos la textura de la imagen
	var img = load_image(SAVE_SCREENS_PATH + _name)
	#Agregamos el screen de la escena guardada o no guardada
	item.set_texture_normal(img)
	#Agregamos la fecha
	var date = item.get_node("Label")
	date.text = scene.id
	#Agregamos la ruta de la escena
	item.scenePath = scene.path
	#Agregamos parent 
	item.parent = self
	#Agregamos banderita si la celda es vacia o llena 
	item.empty = empty
	item.id = scene.id
	item.path = scene.path
	#Guardamos items
	all_items.append(item)
	#Agregamos el grid a la escena
	item_content.add_child(item)

func _on_pressed(scenePath:String):
	#Validamos si existe la ruta de la escena
	if (scenePath):
		#Cambio de escena
		get_tree().paused = false
		SceneTransition.change_scene(scenePath)
		
func clear():
	#Recorremos todos los items del grid
	for item in all_items:
		if item != null:
			#Reseteamos el estado
			item.reset()
			
func load_image(path: String):
	#Validamos si el archivo existe
	if not FileAccess.file_exists(path):
		return # No existe el archivo salimos
	#Leemos el archivo
	var file = FileAccess.open(path, FileAccess.READ)
	#Obtenemos el bufer del archivo
	var buffer = file.get_buffer(file.get_length())
	#Creamos nueva imagen
	var image = Image.new()
	#Guardamos datos a la imagen
	image.load_jpg_from_buffer(buffer)
	#Creamos textura
	return ImageTexture.create_from_image(image)
