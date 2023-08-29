extends Node2D
## Clase que guarda y lee el avance en el juego
##
## Crea las celdas para guardar el avance, prellena los puntos guardados, carga la escena guardada, limpia las celdas del listado de guardado


# DOCUMENTACIÓN GUARDAR Y CARGAR EL AVANCE EN EL JUEGO: https://docs.google.com/document/d/1-mXoGmFTUdLby_V4wx4xU_idy6a0RdYuHLagJxLGakw
# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

# Ruta de Screens guardados
const SAVE_SCREENS_PATH := "user://screens/"

# Declaramos el boton Guardar
@export var actions : VBoxContainer

# Declaramos el boton Guardar
@export var save_button : Button

# Declaramos el boton Guardar
@export var load_button : Button

# Declaramos el boton Guardar
@export var remove_button : Button

# Declaramos el contenedor de confirmación de guardado
@export var save_confirm : VBoxContainer

# Declaramos el contenedor de confirmación de eliminar
@export var delete_confirm : VBoxContainer
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Referencia a todas las "cajas", que contienen objetos
var item_contents = []

# Referencia a todas las "cajas", que contienen objetos
var all_items = []

# Referencia de total de escenas disponibles
var total_items = 6

#Cargamos la escena del item vacío
var _item_content_scene = preload(
		"res://scenes/game/levels/saved_game/item_content/item_content.tscn"
)

# Cargamos la escena del item
var _item_to_load = preload(
		"res://scenes/game/levels/saved_game/item/item.tscn"
)

# Configuracion del item por defecto
var lock = {
	"name": "lock",
	"path": "",
	"id":"",
}

# Enlazamos grid container
@onready var grid = $GridContainer


func _ready():
	# Limpiamos grid
	grid.reset_size()
	# Recorremos el total disponible de escenas
	for n in total_items:
		# Cargamos el contenedor de escenas
		var item = _item_content_scene.instantiate()
		# Agregamos escena al grid
		grid.add_child(item)
		# Guardamos el item del grid
		item_contents.append(item)
	# Inicializamos la revision de datos guardados
	init()


func _on_pressed(scenePath:String):
	# Validamos si existe la ruta de la escena
	if scenePath:
		# Cambio de escena
		get_tree().paused = false
		SceneTransition.change_scene(scenePath)


func init():
	for item in all_items:
		# Reseteamos el estado
		if item != null:
			item.queue_free()

	# Cargamos datos guardados
	var data = SaveProgress.load_game()
	# Validamos si hay datos guardados
	if data and data.point.size():
		# Recorremos el total disponible de escenas
		for n in total_items:
			# Si la escena guardada existe ponemos el screen de la escena
			if data.point.size() > n and data.point[n]:
				# Ponemos el screen de la escena
				_add_item_by_name(data.point[n],n)
			else:
				# Ponemos el screen de la escena no guardada
				_add_item_by_name(lock,n,true)
	else:
		# Ponemos los screens de las escenas no guardadas
		_fill_lock_img()


func _fill_lock_img():
	# Recorremos el total disponible de escenas
	for n in total_items:
		# Ponemos los screens de las escenas no guardadas
		_add_item_by_name(lock,n,true)


func _add_item_by_name(scene: Dictionary, index:int, empty=false):
	# Si no existe el recurso, se termina la función
	if not _item_to_load:
		return
	# Seleccionamos el gred actual
	var item_content = item_contents[index]
	# Inicializamos el gred actual
	var item = _item_to_load.instantiate()
	# Generamos el nombre de la imagen
	var _name = (scene.id + ".jpg").replace(" ", "_").replace(":", "_")
	# Obtenemos la textura de la imagen
	var img = _load_image(SAVE_SCREENS_PATH + _name)
	# Agregamos el screen de la escena guardada o no guardada
	item.set_texture_normal(img)
	# Agregamos la fecha
	var date = item.get_node("Label")
	date.text = scene.id
	# Agregamos la ruta de la escena
	item.scene_path = scene.path
	# Agregamos parent 
	item.parent = self
	# Agregamos banderita si la celda es vacia o llena 
	item.empty = empty
	item.id = scene.id
	item.path = scene.path
	# Guardamos items
	all_items.append(item)
	# Agregamos el grid a la escena
	item_content.add_child(item)


func clear():
	# Recorremos todos los items del grid
	for item in all_items:
		if item != null:
			# Reseteamos el estado
			item.reset()


func _load_image(path: String):
	# Validamos si el archivo existe
	if not FileAccess.file_exists(path):
		return # No existe el archivo salimos
	# Leemos el archivo
	var file = FileAccess.open(path, FileAccess.READ)
	# Obtenemos el bufer del archivo
	var buffer = file.get_buffer(file.get_length())
	# Creamos nueva imagen
	var image = Image.new()
	# Guardamos datos a la imagen
	image.load_jpg_from_buffer(buffer)
	# Creamos textura
	return ImageTexture.create_from_image(image)
