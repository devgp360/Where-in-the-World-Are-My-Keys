extends CanvasLayer
# DOCUMENTACIÓN: https://docs.google.com/document/d/1wEfx7wOw5FJ0GpRLCWUPQObmkE-fCed8TOZk5ZRGOyU/edit#heading=h.e2j6ax5ma83s
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw

# Referencias de nodos del puzzle
@onready var close = $Panel/Button
@onready var sprite = $Panel/Sprite2D
@onready var grid = $Panel/GridContainer
@onready var label = $Panel/Label
@onready var sprites = $Panel/Node2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

var left_items_names = [] # Guarda los nombres de los items
var left_items = [] # Guarda los items (fragmentos)
var left_items_panes = [] # Guarda el contendor de items
var current_item_left_selected = "" # El item actual seleccionado
var total_items = 0 # Total de items recolectados
var total_items_correct = 0 # Total de items colocados correctamente
var is_active = false # Indica si el puzzle se pude "jugar"

# Función de inicialización
func _ready():
	close.pressed.connect(close_click) # Agregamos evento de clic en el botón de cerrar

# Función de cerrar el puzzle.
func close_click():
	set_visible(false)

# Función que muestra/oculta el puzzle
func _set_visible(_visible: bool):
	# Agregamos items al puzzle, según los que tengamos recolectados
	_add_fragments_from_inventory()
	# Texto a mostrar por defecto
	var text = "Se deben seleccionar los fragmentos y girarlos para colocarlos en el lugar correcto"
	# Validamos si todavía no hemos conseguido las 5 piezas, no podremos jugar el puzzle
	if total_items < 5:
		text = "Todavía faltan algunos fragmentos para resolver el puzle... debería encontrarlos primero"
		is_active = false
	# Validamos si tenemos los lentes puestos
	if InventoryCanvas.is_wearing("glasses"):
		# Agregamos todos los colores a la imagen
		sprite.modulate = Color(1, 1, 1)
		if total_items >= 5: # Activamos el puzzle, si ya tenemos todas las piezas
			is_active = true
	else:
		# Agregamos un filtro de escala de grises
		sprite.modulate = Color(0.1, 0.1, 0.1)
		# Todavía tenemos que conseguir los lentes
		text = "La imagen no se ve bien. Tal vez falta algo..."
		is_active = false
	
	label.text = text # Agregamos el mensaje
	self.visible = _visible # Mostramos/Ocultamos el puzzle

# Añadimos los fragmentos recolectados desde el inventario al puzzle
func _add_fragments_from_inventory():
	for _name in InventoryCanvas.get_item_list_names():
		# Agregamos los items para el puzzle "vidriera", excepto los lentes
		if _name.begins_with("puzzle_vidriera/") and !_name.contains("item_lentes"):
			# Cargamos el recurso
			var item = load("res://Inventory/items/" + _name + ".tscn")
			if not item:
				return # Si no existe el recurso, se termina la función
			# Se agrega el item si no está agregado todavía
			if left_items_names.find(_name) == -1:
				var i = item.instantiate()
				var p = ColorRect.new()
				p.color = Color(0, 0, 0, 0)
				p.set_custom_minimum_size(Vector2(80, 80))
				p.add_child(i)
				grid.add_child(p)
				# Guardamos las referencias de los nodos
				left_items_names.append(_name)
				left_items.append(i)
				left_items_panes.append(p)
				# Conectamos el evento clic a los fragmentos
				i.pressed.connect(_click.bind(_name))
				total_items = total_items + 1 # Sumamos en 1 los elementos recolectados
				
				# Agregamos un punto de referencia al centro, para rotar el item desde el centro
				# El item mide 80x80, por lo tanto el centro es 40 en los ejes "x" y "y"
				i.set_pivot_offset(Vector2(40, 40))
				i.set_rotation_degrees(270) # Agregamos rotación por defecto

# Clic en un item, que está del lado izquierdo (fragmento recolectado)
func _click(_name: String):
	if !is_active:
		return # Si no se tienen los lentes, no se podrán seleccionar objetos
	
	var index = left_items_names.find(_name)
	if index >= 0:
		# En el primer clic, colocamos como activo el item
		if current_item_left_selected != _name:
			current_item_left_selected = _name
			for cr in left_items_panes:
				cr.color = Color(0, 0, 0, 0) # Quitamos el color de "selección" de otros items
			var p = left_items_panes[index]
			p.color = Color(0.5, 0.5, 0.5)
			return
		# Para el segundo clic, empezamos a rotar la imagen (en 45 grados)
		var item: TextureButton = left_items[index]
		var deg = item.get_rotation_degrees() + 45 # Agregamos 45 grados de rotación
		if deg >= 360:
			deg = 0 # Si ya llegamos a los 360 grados, volvemos a iniciar en 0
		item.set_rotation_degrees(deg)

# Clic en un área donde se mostrarán los items ya "colocados" en su sitio correcto
func _click_event(_name: String):
	if !is_active:
		return # Si no se tienen los lentes, no se podrán mover objetos
	# Si no tenemos un fragmento seleccionado, mostramos un mensajes y terminamos la función
	if current_item_left_selected == "":
		label.text = "No hay ningún fragmento seleccionado"
		return
	else:
		# Buscamos que item tenemos selecionado
		var index = left_items_names.find(current_item_left_selected)
		if index >= 0 and current_item_left_selected.contains(_name):
			# Validamos que esté en el ángulo correcto
			var item = left_items[index]
			var deg = item.get_rotation_degrees()
			if deg == 0: # El ángulo correcto debe ser 0
				label.text = "Correcto, hemos agregado un fragmento!"
				# Dependiendo a que area se dio clic, buscamos y hacemos visible el fragmento correcto
				set_correct_fragment(_name)
				# Luego quitamos el fragmento, del listado que está al lado izquierdo
				var p = left_items_panes[index]
				grid.remove_child(p)
				left_items_panes.remove_at(index)
				left_items_names.remove_at(index)
				left_items.remove_at(index)
				total_items_correct = total_items_correct + 1
				
				if total_items_correct == 5:
					label.text = "Lo hemos conseguido. El mensajes oculto es ¿¡mensaje oculto!?."

				return
		label.text = "No es el lugar correcto o la rotación no es correcta"

# Función que pone como visible un fragmento "colocado" correctamente
func set_correct_fragment(_name: String):
	if _name == "vidrio1":
		sprites.find_child("Sprite1").visible = true
	elif _name == "vidrio2":
		sprites.find_child("Sprite2").visible = true
	elif _name == "vidrio3":
		sprites.find_child("Sprite3").visible = true
	elif _name == "vidrio4":
		sprites.find_child("Sprite4").visible = true
	elif _name == "vidrio5":
		sprites.find_child("Sprite5").visible = true
