extends Node2D

@onready var main_sprite: Sprite2D = $SpriteBack
@onready var brebaje: Sprite2D = $SpriteBack/Brebaje
@onready var btn_limpiar = $SpriteBack/Control/Limpiar
@onready var btn_mezclar = $SpriteBack/Control/Mezclar
@onready var btn_inventario = $SpriteBack/Control/Inventario

var pos = Vector2(0, 0)
var showing_potion = false
var plants = [] # Para guardar que plantas se han "agregado"
signal on_blend()
signal on_hide_potion()
signal on_add_inventory()

var plant_color_map = {
	"ruda": 0.3,
	"romero": 0.7,
	"equinacea": 0.1,
	"chaya": 0.2,
	"aloe_vera": 0.5,
}

# Función de inicialización
func _ready():
	reset()
	btn_limpiar.pressed.connect(clear)
	btn_mezclar.pressed.connect(blend)
	btn_inventario.pressed.connect(add_inventory)
	pos = self.position

# Reseteamos el item (colocamos el vaso "vacío" y de nuevo a la posición inicial)
func reset():
	remove_all_plants()
	check_btn_blend()
	brebaje.visible = false
	btn_inventario.visible = false

# Pone visible la imagen de la planta a agregar. Máximo 3. 
# Si se pudo agregar se retorna true, de lo contrario false.
func add_plant(name: String):
	if plants.size() == 3: # Solo se podrán agregar 3 plantas como máximo
		return false
	var child = main_sprite.find_child("Plant_" + name)
	if child:
		child.visible = true
		plants.append(name)
		check_btn_blend()
		return true
	return false

# Valida y retorna true, si la planta ya está visible "agregada"
func exists_plant(name: String):
	return plants.find(name) >= 0

# Oculta todas las plantas del vaso.
func remove_all_plants():
	for sprite in main_sprite.get_children():
		if sprite.name.begins_with("Plant_"):
			sprite.visible = false
	plants = []

# Permite asociar un función, para escuchar cuando se mezclen las plantas
func add_on_blend(fn):
	on_blend.connect(fn)

# Permite asociar un función, para escuchar cuando se oculte el brebaje
func add_on_hide_potion(fn):
	on_hide_potion.connect(fn)
	
# Permite asociar un función, para escuchar cuando se oculte el brebaje
func add_on_add_inventory(fn):
	on_add_inventory.connect(fn)

# Dispara la señal de mezclar las plantas, y ejectua los eventos asociados
func blend():
	on_blend.emit()

# Se ejecuta cuando se presiona el botón "limpiar"
func clear():
	reset()
	if showing_potion:
		showing_potion = false
		self.position = pos
		on_hide_potion.emit()

# Añadimos al inventario
func add_inventory():
	InventoryCanvas.add_item_by_name("puzzle_jardin/item_brebaje_1", {
		"modulate": brebaje.modulate
	})
	clear()
	on_add_inventory.emit()

# Muestra el botón de "mezclar" cuando se tiene 3 plantas agregadas
func check_btn_blend():
	if plants.size() == 3:
		btn_mezclar.visible = true
	else:
		btn_mezclar.visible = false

# Muestra una vevida de un color, dependiendo de las plantas y el orden recolectado
func show_potion(pos: Vector2):
	if !plants.size() == 3:
		return
	var r = plant_color_map[plants[0]]
	var g = plant_color_map[plants[1]]
	var b = plant_color_map[plants[2]]
	remove_all_plants() # Quitamos todas las plantas del vaso
	brebaje.visible = true
	brebaje.modulate = Color(r, g, b) # Seteamos color
	self.position = pos # Seteamos posición (al centro)
	check_btn_blend() # Mostrar/Ocultar botón "mezclar"
	btn_inventario.visible = true
	showing_potion = true
