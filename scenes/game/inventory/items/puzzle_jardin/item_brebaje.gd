extends Button
## Clase que controla la poción del rompecabezas de jardin 
## 
## Se controlan las colisiones y eventos del ratón, y se agregan o se consultan los parámetros de objetos


# DOCUMENTACIÓN (catálogo de objetos): https://docs.google.com/document/d/1aFTTLLd4Yb8T_ntjjGlv4LHEGgnz8exqdcbFO9XK3MA/edit?usp=drive_link

var _params = null # Parámetros que se pueden pasar a un item de inventario
var _is_item_selected = false # Para indicar si el item está seleccionado

@onready var brebaje = $back/brebaje
@onready var buttons = $Buttons
@onready var timer = $Timer
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc/edit#heading=h.ebe9jjxfmain


# Función de inicialización
func _ready():
	buttons.visible = false


# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Se ejecuta cuando el cursor entra en el objeto
func _on_mouse_entered():
	if _is_item_selected:
		return
	buttons.visible = true


# Se ejecuta cuando el cursor sale del objeto
func _on_mouse_exited():
	if _is_item_selected:
		return
	timer.start()
	await timer.timeout
	buttons.visible = false


# Cuando se presiona el botón "usar"
func _on_usar_pressed():
	if _is_item_selected:
		return
	self.pressed.emit()


# Cuando se presiona el botón "usar con"
func _on_usar_con_pressed():
	if _is_item_selected:
		return
	# Seleccionamos el item desde el inventario
	InventoryCanvas.select_item_to_use("puzzle_jardin/item_brebaje_1", true)


# Agregar parámetros al item
func add_params(_name: String, params):
	if _name == "puzzle_jardin/item_brebaje_1":
		# Agregamos parámetro de color
		brebaje.modulate = params["modulate"]
		self.params = params


# Devolvemos los parámetros del item
func get_params():
	return _params


# Cuando se da clic directo al item
func set_item_selected():
	_is_item_selected = true
	self.z_index = 20
	self.y_sort_enabled = false
	self.z_as_relative = false
