extends Button

@onready var brebaje = $back/brebaje
@onready var buttons = $Buttons
@onready var timer = $Timer

var params = null
var is_item_selected = false

# Función de inicialización
func _ready():
	buttons.visible = false

# Agregar parámetros al item
func add_params(name: String, params):
	if name == "puzzle_jardin/item_brebaje_1":
		# Agregamos parámetro de color
		brebaje.modulate = params["modulate"]
		self.params = params

# Devolvemos los parámetros del item
func get_params():
	return params

# Se ejecuta cuando el cursor entra en el objeto
func _on_mouse_entered():
	if is_item_selected:
		return
	buttons.visible = true

# Se ejecuta cuando el cursor sale del objeto
func _on_mouse_exited():
	if is_item_selected:
		return
	timer.start()
	await timer.timeout
	buttons.visible = false

# Cuando se presiona el botón "usar"
func _on_usar_pressed():
	if is_item_selected:
		return
	self.pressed.emit()

# Cuando se presiona el botón "usar con"
func _on_usar_con_pressed():
	if is_item_selected:
		return
	# Seleccionamos el item desde el inventario
	InventoryCanvas.select_item_to_use("puzzle_jardin/item_brebaje_1", true)

# Cuando se da clic directo al item
func set_item_selected():
	is_item_selected = true
	self.z_index = 20
	self.y_sort_enabled = false
	self.z_as_relative = false
