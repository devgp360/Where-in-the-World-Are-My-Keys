extends Node
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN (catálogo de objetos): https://docs.google.com/document/d/1aFTTLLd4Yb8T_ntjjGlv4LHEGgnz8exqdcbFO9XK3MA/edit?usp=drive_link

@export var area: Area2D # Area de colisión del item
@export var button: TextureButton # Nodo tipo botón que representa el item
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc
@export var is_inventory_item = true # Para diferenciar item de inventario y escena
@export var item_title = "Item" # Título/Nombre del item
@export var item_text_pickup = "Tomar" # Texto para mostrar que se puede "tomar" el item
@export var item_path_name = "" # Ruta + nombre del nodo para cargarlo en el inventario
#Definición del reproductor del sonido
@export var anim_player: AudioStreamPlayer2D

var is_character_entered = false # Indica si el personaje entró en contacto con el item


# Función de inicialización
func _ready():
	button.tooltip_text = item_title # Se inicializa el nombre del objeto
	if !is_inventory_item:
		# Conectamos los eventos para "tomar" un objeto (en caso sea un objeto de escena)
		# DOCUMENTACIÓN (señales): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
		button.pressed.connect(click_in_escene)
		area.area_entered.connect(area_entered)
		area.area_exited.connect(area_exited)


# Se ejecuta, cuando se da clic a un item que está en una escena (para ser recolectado)
func click_in_escene():
	# Si el personaje principal está "cerca" del ítem, se podrá "tomar".
	if is_character_entered:
		pick_up() # Función que "toma" el item


# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link
# Se ejecuta cuando el personaje principal se acerca al item
func area_entered(_area: Area2D):
	if (_area.name == 'mainchar_area'):
		# Validamos que sea el personaje principal, el que entró en contacto con el item
		is_character_entered = true # Guardamos que estamos en el área del item
		set_tooltip() # Modificamos el tooltip del botón


# Se ejecuta cuando el personaje principal se aleja del item
func area_exited(_area: Area2D):
	if (_area.name == 'mainchar_area'):
		# Validamos que sea el personaje principal, el que salió del área de contacto con el item
		is_character_entered = false # Guardamos que ya no estamos en el área del item
		set_tooltip() # Modificamos el tooltip del botón


# Cambia el texto que se muestra al estar encima del item
func set_tooltip():
	if (is_character_entered):
		# Si estamos cerca del objeto, agregamos un texto como: "tomar item".
		button.tooltip_text = item_text_pickup + " " + item_title
	else:
		# Si no estamos cerca del objeto, agregamos el nombre del item como tooltip
		button.tooltip_text = item_title


# Función que oculta el item del escenario y lo agrega al inventario
func pick_up():
	button.visible = false
	InventoryCanvas.add_item_by_name(item_path_name)
	if anim_player:
		anim_player.play()


# Retorna la "ruta" del item
func get_path_name():
	return item_path_name
