extends CanvasLayer
## Clase que controla el rompecabezas de vidriera 
## 
## Muestra y quita la ventana de rompecabezas, controla pistas del puzle, visualiza los fragmentos de vidrio disponibles, gira los objetos de vidrio alrededor de su eje 
## Pone fragmentos de vidrio en su posición correcta


# DOCUMENTACIÓN: https://docs.google.com/document/d/1wEfx7wOw5FJ0GpRLCWUPQObmkE-fCed8TOZk5ZRGOyU/edit#heading=h.e2j6ax5ma83s
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw

# Variables de textos para mostrar durante el puzzle
@export var TEXT_SELECT_FRAGMENT = "Se deben seleccionar los fragmentos y girarlos para colocarlos en el lugar correcto"
@export var TEXT_FRAGMENTS_INCOMPLETE = "Todavía faltan algunos fragmentos para resolver el puzle... debería encontrarlos primero"
@export var TEXT_NO_GLASSES = "La imagen no se ve bien. Tal vez falta algo..."
@export var TEXT_NO_SELECTED = "No hay ningún fragmento seleccionado"
@export var TEXT_FRAGMENT_ADDED = "Correcto, hemos agregado un fragmento!"
@export var TEXT_SUCCESS = "Lo hemos conseguido. El mensajes oculto es ¿¡mensaje oculto!?."
@export var TEXT_INCORRECT = "No es el lugar correcto o la rotación no es correcta"

# Guarda los nombres de los items
var _left_items_names = []
# Guarda los items (fragmentos)
var _left_items = []
# Guarda el contendor de items
var _left_items_panes = []
# El item actual seleccionado
var _current_item_left_selected = ""
# Total de items recolectados
var _total_items = 0
# Total de items colocados correctamente
var _total_items_correct = 0
# Indica si el puzzle se pude "jugar"
var _is_active = false

# Referencias de nodos del puzzle
@onready var close = $Container/CloseButton
@onready var sprite = $Container/MainSprite
@onready var grid = $Container/RecolectedFragmentsGrid
@onready var label = $Container/FeedbackText
@onready var sprites = $Container/CorrectFragmentGroup
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	set_visible(false) # Cuando cargamos el puzzle, por defecto no se muestra
	# Agregamos evento de clic en el botón de cerrar
	close.pressed.connect(_close_click)


# Función de cerrar el puzzle.
func _close_click():
	set_visible(false)


# Función que muestra/oculta el puzzle
func _set_visible(_visible: bool):
	# Agregamos items al puzzle, según los que tengamos recolectados
	_add_fragments_from_inventory()
	# Texto a mostrar por defecto
	var _text = TEXT_SELECT_FRAGMENT
	# Validamos si todavía no hemos conseguido las 5 piezas, no podremos jugar el puzzle
	if _total_items < 5:
		_text = TEXT_FRAGMENTS_INCOMPLETE
		_is_active = false
	# Validamos si tenemos los lentes puestos
	if InventoryCanvas.is_wearing("Glasses"):
		# Agregamos todos los colores a la imagen
		sprite.modulate = Color(1, 1, 1)
		if _total_items >= 5: # Activamos el puzzle, si ya tenemos todas las piezas
			_is_active = true
	else:
		# Agregamos un filtro de escala de grises
		sprite.modulate = Color(0.1, 0.1, 0.1)
		# Todavía tenemos que conseguir los lentes
		_text = TEXT_NO_GLASSES
		_is_active = false
	
	label.text = _text # Agregamos el mensaje
	self.visible = _visible # Mostramos/Ocultamos el puzzle


# Añadimos los fragmentos recolectados desde el inventario al puzzle
func _add_fragments_from_inventory():
	for _name in InventoryCanvas.get_item_list_names():
		# Agregamos los items para el puzzle "vidriera", excepto los lentes
		if _name.begins_with("puzzle_vidriera/") and not _name.contains("item_lentes"):
			# Cargamos el recurso
			var _item = load("res://scenes/game/inventory/items/" + _name + ".tscn")
			if not _item:
				return # Si no existe el recurso, se termina la función
			# Se agrega el item si no está agregado todavía
			if _left_items_names.find(_name) == -1:
				var i = _item.instantiate()
				var p = ColorRect.new()
				p.color = Color(0, 0, 0, 0)
				p.set_custom_minimum_size(Vector2(80, 80))
				p.add_child(i)
				grid.add_child(p)
				# Guardamos las referencias de los nodos
				_left_items_names.append(_name)
				_left_items.append(i)
				_left_items_panes.append(p)
				# Conectamos el evento clic a los fragmentos
				i.pressed.connect(_click.bind(_name))
				_total_items = _total_items + 1 # Sumamos en 1 los elementos recolectados
				
				# Agregamos un punto de referencia al centro, para rotar el item desde el centro
				# El item mide 80x80, por lo tanto el centro es 40 en los ejes "x" y "y"
				i.set_pivot_offset(Vector2(40, 40))
				i.set_rotation_degrees(270) # Agregamos rotación por defecto


# Clic en un item, que está del lado izquierdo (fragmento recolectado)
func _click(_name: String):
	if not _is_active:
		return # Si no se tienen los lentes, no se podrán seleccionar objetos
	
	var _index = _left_items_names.find(_name)
	if _index >= 0:
		# En el primer clic, colocamos como activo el item
		if _current_item_left_selected != _name:
			_current_item_left_selected = _name
			for cr in _left_items_panes:
				cr.color = Color(0, 0, 0, 0) # Quitamos el color de "selección" de otros items
			var p = _left_items_panes[_index]
			p.color = Color(0.5, 0.5, 0.5)
			return
		# Para el segundo clic, empezamos a rotar la imagen (en 45 grados)
		var _item: TextureButton = _left_items[_index]
		var _deg = _item.get_rotation_degrees() + 45 # Agregamos 45 grados de rotación
		if _deg >= 360:
			_deg = 0 # Si ya llegamos a los 360 grados, volvemos a iniciar en 0
		_item.set_rotation_degrees(_deg)


# Clic en un área donde se mostrarán los items ya "colocados" en su sitio correcto
func _click_event(_name: String):
	if not _is_active:
		return # Si no se tienen los lentes, no se podrán mover objetos
	# Si no tenemos un fragmento seleccionado, mostramos un mensajes y terminamos la función
	if _current_item_left_selected == "":
		label.text = TEXT_NO_SELECTED
		return
	else:
		# Buscamos que item tenemos selecionado
		var _index = _left_items_names.find(_current_item_left_selected)
		if _index >= 0:
			# Validamos que esté en el ángulo correcto
			var _item = _left_items[_index]
			var _deg = _item.get_rotation_degrees()
			if _deg == 0: # El ángulo correcto debe ser 0
				label.text = TEXT_FRAGMENT_ADDED
				# Dependiendo a que area se dio clic, buscamos y hacemos visible el fragmento correcto
				_set_correct_fragment(_name)
				# Luego quitamos el fragmento, del listado que está al lado izquierdo
				var _p = _left_items_panes[_index]
				grid.remove_child(_p)
				_left_items_panes.remove_at(_index)
				_left_items_names.remove_at(_index)
				_left_items.remove_at(_index)
				_total_items_correct = _total_items_correct + 1
				
				if _total_items_correct == 5:
					label.text = TEXT_SUCCESS

				return
		label.text = TEXT_INCORRECT


# Función que pone como visible un fragmento "colocado" correctamente
func _set_correct_fragment(_name: String):
	if _name == "AreaFragment1":
		sprites.find_child("Fragment1").visible = true
	elif _name == "AreaFragment2":
		sprites.find_child("Fragment2").visible = true
	elif _name == "AreaFragment3":
		sprites.find_child("Fragment3").visible = true
	elif _name == "AreaFragment4":
		sprites.find_child("Fragment4").visible = true
	elif _name == "AreaFragment5":
		sprites.find_child("Fragment5").visible = true
