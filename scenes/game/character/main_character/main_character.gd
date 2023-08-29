extends CharacterBody2D
## Clase que controla el comportamiento de personaje principal 
## 
## Crea la sombra, animaciones, del personaje, busca el camino más corto, calcula el tamaño del personaje en base de posición en la escena 
## Maneja los objetos puestos (como lentes etc.), agrega objetos al inventario

# DOCUMENTACIÓN SOBRE MOVIMIENTOS DE UN PERSONAJE: https://docs.google.com/document/d/1V__ENMBZUavTCnd7BxHF1oI3gDAOhPtwU5DRxlDGb4g
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw
# DOCUMENTACIÓN TOOLTIPS PARA DIÁLOGOS CON NPCS: https://docs.google.com/document/d/15bKBdC0nMawhdyuVRRfcZbFD7D59Lb8HhKiGBY70FL0
# DOCUMENTACIÓN (creación de personaje): https://docs.google.com/document/d/1mwEdhKQrObfhGChXO0R31xknLabwwrc8yRvXdaWJBwE/edit?usp=drive_link

signal picked_object(name: String) # Señal para que saber cuando se recogió un objeto en una escena

# Las diferentes animaciones que tiene el personaje (el nombre es igual al nombre creado en cada animación)
const ANIM_IDLE := "idle"
const ANIM_IDLE_LEFT := "idle_left"
const ANIM_IDLE_RIGHT := "idle_right"
const ANIM_IDLE_UP := "idle_up"
const ANIM_IDLE_DOWN := "idle_down"
# Animaciones de movimiento para el personaje (cuando camina)
const ANIM_LEFT := "left"
const ANIM_RIGHT := "right"
const ANIM_FRONT := "front"
const ANIM_BACK := "back"
const ANIM_UP_LEFT = "up_left"
const ANIM_UP_RIGHT = "up_right"
const ANIM_DOWN_LEFT = "down_left"
const ANIM_DOWN_RIGHT = "down_right"
# Direcciones hacia donde se puede mover el personaje (8 direcciones)
const DIRECTION_LEFT = "left"
const DIRECTION_RIGHT = "right"
const DIRECTION_UP = "up"
const DIRECTION_DOWN = "down"
const DIRECTION_UP_LEFT = "up-left"
const DIRECTION_UP_RIGHT = "up-right"
const DIRECTION_DOWN_LEFT = "down-left"
const DIRECTION_DOWN_RIGHT = "down-right"
const DIRECTION_IDLE = "idle"
# Ruta completa de assets de personaje
const SPRITE_PATH = "res://assets/sprites/character/main/"
# Constantes de sombra
# BOTTON: Personaje "debajo" del punto de luz
# TOP: Personaje "arriba" del punto de luz
const SHADER_OFFSET_Y_BOTTOM = 2.0 # Posición de sombra en Y (en BOTTOM)
const SHADER_OFFSET_Y_TOP = -80.0 # Posición de sombra en Y (en TOP)
const SHADER_DEFORM_Y = 1.0 # La sombra es la mitad del tamaño de personaje (en el punto 0 en X)
const SHADER_OFFEXT_X_FACTOR_BOTTOM = 250.0 # Posición de sombra en X (en BOTTOM)
const SHADER_OFFSET_X_FACTOR_TOP = 150.0 # Posición de sombra en X (en TOP)

# Referencias de personajes/objetos en la escena
@export var npc1: CharacterBody2D
@export var door: Node2D
@export var inventory: CanvasLayer
# Variables para generar sombra con shader en el personaje
@export var light_node: Node2D # Un punto de referencia (desde donde se genera luz)
# Cambiando estos valores se pueden tener sombras más suaves o fuertes
#  se pueden variar por escena para el personaje
@export var shadow_min_value = 0.1 # Valor de sombra mínimo (0.0 a 1.0)
@export var shadow_max_value = 0.9 # Valor de sombra máximo (0.0 a 1.0)

# Variables que modifican el comportamiento del personaje principal (se pueden modificar)
@export var speed := 220 # Velocidad de movimiento de izquierda a derecha

# Variables para "fake z-axis". Se usan para hacer el personaje más pequeño o más grande
# dependiendo de su posición en el eje Y
# Escalas: las escalas mínima y máxima, aseguran que el personaje no se salga de esas escalas
# También sirve para poder alejar o acercar el personaje en mayor o menor proporción (agrandar o reducir más rápido o lento)
# Mínimo/Máximo en eje "Y": sirve para definir el rango de movimiento en el eje Y. No debe ser exacto, si no aproximado
# para poder ver que tanto efecto de acercamiento o alejamiento se necesita.
@export var active_fake_z_axis = false
@export var min_scale = 0.5 # Escala mínima que podrá tener el personaje
@export var max_scale = 2.5 # Escala máxima que podrá tener el personaje
@export var min_y = -500.0 # El eje "Y" mínimo hasta donde debería llegar el personaje
@export var max_y = 800.0 # El eje "Y" máximo hasta donde debería llegar el personaje

# Si esta variable es falsa, el personaje no se podrá mover ni animar.
var _character_active = true
# Vector de destino, para path-finding
var _destination = Vector2(0, 0);
var _main_direction = DIRECTION_IDLE # Variable que guarda la dirección hacia donde se mueve el personaje
var _main_animation = ANIM_IDLE # Variable que guarda la animación que se está mostrando del personaje
var _path_finding_moving = false;
# Listado de items "activos" que el personaje principal debe usar
var _dress_item_list = []
# Guarda los sprites para animación del personaje
var _animations = []

@onready var anim := $Sprite2D/AnimationSprite # Animaciones
@onready var sprite := $Sprite2D # Sprite principal del personaje
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var clothes:= $Sprite2D/Clothes # Nodo principal que contiene nodos de vestimenta del personaje
@onready var sound_step:= $AudioStreamPlayer2D # Sonido de pasos
@onready var dialog_label = $DialogLabel # Etiqueta para mostrar textos
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	picked_object.connect(_add_object_to_inventory)
	
	# Validamos si el personaje está vistiendo un item
	if InventoryCanvas.is_wearing("Glasses"):
		dress_item("Glasses", true)
	
	# Para un manejo más fácil de sombras con "shaders", se separó las animaciones del personaje
	# en varias imágenes separadas, que se cargarán al cargar el personaje
	# DOCUMENTACIÓN (sprites): https://docs.google.com/document/d/1b1I-xoUz6QkS5G6VtHhR9MZn40IGy3ZWObMCeorJjGg/edit?usp=drive_link
	_animations = [
		load(SPRITE_PATH + "idle.png"),
		load(SPRITE_PATH + "back.png"),
		load(SPRITE_PATH + "front.png"),
		load(SPRITE_PATH + "left.png"),
		load(SPRITE_PATH + "right.png"),
		load(SPRITE_PATH + "up_left.png"),
		load(SPRITE_PATH + "up_right.png"),
		load(SPRITE_PATH + "down_left.png"),
		load(SPRITE_PATH + "down_right.png"),
	]
	
	# Test vidriera
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_lentes")
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_vidrio1")
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_vidrio2")
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_vidrio3")
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_vidrio4")
	InventoryCanvas.add_item_by_name("puzzle_vidriera/item_vidrio5")
	


# Captura eventos del teclado o ratón
func _unhandled_input(event):
	# Si hacemos un clic en alguna parte de la escena
	if event.is_action_pressed("click"):
		#Ancendemos el sonido de pasos
		sound_step.play()
		# Obtenemos la posición donde se dio clic
		_destination = get_global_mouse_position()
		# Agregamos un punto de destino al nodo "NavigationAgent2D"
		nav_agent.target_position = _destination
		# Activamos una "bandera" para iniciar a mover el personaje
		_path_finding_moving = true


# Función que se procesa con cada frame que renderiza el juego
func _physics_process(_delta):
	if not _character_active:
		return # Si el personaje no está activo, no se podrá interactuar con él
	# Cambia de animación el personaje, dependiendo de hacia donde se está moviendo
	_set_animation()
	# Busca una ruta de navegación, cuando se da clic en un punto de la escena
	_path_finding()
	# Se calcula la escala del personaje (fake z-axis)
	_calc_scale()
	# Validamos que items tiene activos el personaje para "vestir"
	_process_dress_item()
	# Procesa un shader para generar una sombra del personaje
	_dynamic_shader()


# DOCUMENTACIÓN (animaciones): https://docs.google.com/document/d/13ZWMjST6pT7EIjfe6JRyLGqJAG-NdahEWABhnN1VzuY/edit?usp=drive_link
# DOCUMENTACIÓN SOBRE MOVIMIENTOS DE UN PERSONAJE: https://docs.google.com/document/d/1V__ENMBZUavTCnd7BxHF1oI3gDAOhPtwU5DRxlDGb4g
# Agrega diferentes tipos de animaciones al personaje, dependiendo de la acción que esté ejecutando:
# Saltar, correr, deslizarse por una pared, etc.
func _set_animation():
	# Sentencia de control, para definir la animación que se está ejecutando según a la dirección
	# que se mueve el personaje. También se setea el "índice" del sprite a usar según la dirección
	# de movimiento del personaje.
	var sprite_image_index = 0
	if _main_direction == DIRECTION_LEFT:
		_main_animation = ANIM_LEFT
		sprite_image_index = 3
	elif _main_direction == DIRECTION_DOWN_LEFT:
		_main_animation = ANIM_DOWN_LEFT
		sprite_image_index = 7
	elif _main_direction == DIRECTION_UP_LEFT:
		_main_animation = ANIM_UP_LEFT
		sprite_image_index = 5
	elif _main_direction == DIRECTION_RIGHT:
		_main_animation = ANIM_RIGHT
		sprite_image_index = 4
	elif _main_direction == DIRECTION_DOWN_RIGHT:
		_main_animation = ANIM_DOWN_RIGHT
		sprite_image_index = 8
	elif _main_direction == DIRECTION_UP_RIGHT:
		_main_animation = ANIM_UP_RIGHT
		sprite_image_index = 6
	elif _main_direction == DIRECTION_UP:
		_main_animation = ANIM_BACK
		sprite_image_index = 1
	elif _main_direction == DIRECTION_DOWN:
		_main_animation = ANIM_FRONT
		sprite_image_index = 2
	else:
		_main_animation = ANIM_IDLE
	anim.play("main") # Siempre es main, ya que lo que cambia es la imagen de "sprite"
	sprite.texture = _animations[sprite_image_index] # Se cambia la textura según la animación


# DOCUMENTACIÓN (rutas): https://docs.google.com/document/d/1lUoLrdHBMhXsEhSxhWwA41vWLvbzNZGaQJ0h23s5rT8/edit?usp=drive_link
# Busca una ruta en el área de navegación para el personaje, y lo mueve en la escena
# DOCUMENTACIÓN SOBRE MOVIMIENTOS DE UN PERSONAJE: https://docs.google.com/document/d/1V__ENMBZUavTCnd7BxHF1oI3gDAOhPtwU5DRxlDGb4g
func _path_finding():
	# Si no está activado el "flag" de mover al personaje, solo terminamos la función
	if not _path_finding_moving:
		return

	# Buscamos el siguiente punto al cual mover el personaje
	var next = nav_agent.get_next_path_position()
	# Devuelve el vector que apunta desde la posición actual del personaje, al siguiente punto
	var local = position.direction_to(next)
	# Retorna un vector normalizado
	var dir = local.normalized()
	# Calculmos la velocidad de movimiento
	velocity = dir * speed
	move_and_slide() # Mover el personaje
	
	# Variable que tiene el ángulo de dirección entre un punto de origen y uno de destino
	var move_direction = rad_to_deg(next.angle_to_point(position))
	
	# Sentencias que setean la variable "main_direction" con la dirección
	# hacia donde se mueve el personaje, según el ángulo de dirección
	if (move_direction <= 15 and move_direction >= -15):
		_main_direction = DIRECTION_LEFT;
	elif move_direction <= 60 and move_direction >= 15:
		_main_direction = DIRECTION_UP_LEFT;
	elif move_direction <= 120 and move_direction >= 60:
		_main_direction = DIRECTION_UP;
	elif move_direction <= 165 and move_direction >= 120:
		_main_direction = DIRECTION_UP_RIGHT;
	elif move_direction >= -60 and move_direction <= -15:
		_main_direction = DIRECTION_DOWN_LEFT;
	elif move_direction >= -120 and move_direction <= -60:
		_main_direction = DIRECTION_DOWN;
	elif move_direction >= -165 and move_direction <= -120:
		_main_direction = DIRECTION_DOWN_RIGHT;
	elif move_direction <= -165 and move_direction >= 165:
		_main_direction = DIRECTION_RIGHT;
	else:
		_main_direction = DIRECTION_RIGHT
	
	if nav_agent.is_navigation_finished():
		_path_finding_moving = false
		_main_direction = DIRECTION_IDLE
	#Si termó caminar el personaje apagamos el sonido de pasos
	if (_main_direction == DIRECTION_IDLE):
		sound_step.stop()


# DOCUMENTACIÓN (profundidad): https://docs.google.com/document/d/1oRxN0jtTm6Db7bcehrl5PncpSlRVaTcg9GB-0gDdwC4/edit?usp=drive_link
# Calcula una escala (tamaño) del personaje, cuando se mueve hacia "arriba", se hace más pequeño
# y cuando se mueve hacia "abajo" se hace más grande.
# DOCUMENTACIÓN SOBRE PROFUNDIDAD EN ESCENAS:https://docs.google.com/document/d/1oRxN0jtTm6Db7bcehrl5PncpSlRVaTcg9GB-0gDdwC4
func _calc_scale():
	if not active_fake_z_axis:
		return # Si no está activido el "fake z-axis" solo terminamos la función
	var v = sprite.get_scale()

	# Calcular la escala en función de la posición vertical
	var scale_factor = (position.y - min_y) / (max_y - min_y)
	var new_scale = lerp(min_scale, max_scale, scale_factor)
	# Actualizmos la escala del objeto
	v.x = new_scale;
	v.y = new_scale;
	# Escalamos el "sprite"
	sprite.set_scale(v)


# DOCUMENTACIÓN (inventario): https://docs.google.com/document/d/1aFTTLLd4Yb8T_ntjjGlv4LHEGgnz8exqdcbFO9XK3MA/edit?usp=drive_link
# DOCUMENTACIÓN (recolectar objetos): https://docs.google.com/document/d/1d78cYa4cTpxfz22lGvctv6T83TSj5DMwq3VMWiGAbI8/edit?usp=drive_link
# Añada objetos al inventario del usuario
func _add_object_to_inventory(_name: String):
	inventory.emit_signal("add_object", _name)


# Función que valida el listado de items activos para vestir, por cada item, define cuando mostrarlo
# Esta función se llama directamente desde "_physics_process" que se ejecuta en cada "frame"
func _process_dress_item():
	# Validamos que tenemos que "vestir" los lentes del puzzle "vidriera".
	var glasses = clothes.find_child("Glasses")
	if not glasses:
		return
	if _dress_item_list.find("Glasses") >= 0: # Si los lentes están "activos"
		var is_front = _main_animation == ANIM_IDLE || _main_animation == ANIM_FRONT
		glasses.visible = is_front # Si el personaje está de frente, se mostrarán los lentes
	else:
		glasses.visible = false


# Función para usar un "item" para el puzzle de "Jardín"
# En este puzzle se usan bebidas, que el personaje, al "consumirlas", mostrará un texto imformativo
func _use_item(_name, params):
	var text = "Ohh, ya me siento " # Texto base
	# Mapa de textos finales (en base a los valores del color de la bebida)
	var mapping = {
		"0.1:0.3:0.7": "fuerte.",
		"0.1:0.7:0.3": "cansado.",
		"0.7:0.1:0.3": "rápido.",
		"0.7:0.3:0.1": "lento.",
		"0.5:0.2:0.1": "lleno. Aunque... parece aceite.",
	}
	if params:
		# Dependiendo del "color" de una bebida, sacamos un texto a mostrar del "mapping"
		var m = params.modulate
		var key_format = "%1.1f:%1.1f:%1.1f"
		var key = key_format % [m.r, m.g, m.b]
		if mapping.has(key):
			text = text + mapping[key]
		else:
			text = text + "mejor." # Si el color no está mapeado, usamos texto por defecto
	dialog_label.text = text


# DOCUMENTACIÓN (sombras): https://docs.google.com/document/d/1IAQRxm-IrOKRFd6XK9IlnbYYaLb_Bt0VDyqVeKR42j0/edit?usp=drive_link
# DOCUMENTACIÓN (sombras por escena): https://docs.google.com/document/d/1CdHJbnfx3h9YIoKqds2iq8BqDV3CVRmkpoKb_0FNAN4/edit?usp=drive_link
# Genera una sombra para el personaje principal. Se calcula
# - La intensidad (dependiendo de la distancia a un punto de referencia)
# - La deformación de sombra (en base al angulo "dirección" del personaje con respecto al punto de referencia)
func _dynamic_shader():
	# Si no está seteado un punto de luz, solo retornamos sin sombra
	if not light_node:
		sprite.material.set("shader_parameter/opacity", 0.0)
		return

	# Dirección de movimiento (desde -180 grados a 180 grados (los 360 grados del círculo)
	var move_direction = rad_to_deg(light_node.position.angle_to_point(position))
	# Si es verdadero, indica que el personaje está por encima del punto de luz
	var character_is_over_light = false
	# Hacemo el vector más pequeño, para que esté en el rango de "unidades"
	move_direction = move_direction * 0.01
	# Si estemos sobre el punto de luz
	if move_direction < 0:
		move_direction = move_direction * -1 # Hacemos negativa la dirección
		character_is_over_light = true # Guardamos que estasmos sobre la luz

	# Calculamos la "deformación" de la sombra
	# Se estira hacia el lado derecho o izquierdo
	var deformY = SHADER_DEFORM_Y
	var deformX = move_direction - 1
	if character_is_over_light:
		deformX = deformX * -1 # Si estamos sobre la luz, hacemos la deformación negativa

	# Calculamos la posición de la sombra, respecto al sprite del personaje
	# La sombra inicia siempre en los "pies" del personaje
	var offsetY = SHADER_OFFSET_Y_BOTTOM;
	var offsetX = deformX * SHADER_OFFEXT_X_FACTOR_BOTTOM;
	if character_is_over_light:
		offsetY = SHADER_OFFSET_Y_TOP
		offsetX = deformX * SHADER_OFFSET_X_FACTOR_TOP;

	# Generamos las variables para pasar al "shader"
	var deform = Vector2(deformX, deformY);
	var offset = Vector2(offsetX, offsetY);

	# Calculamos una opacidad de la sombra, en base a la distancia del personaje a un punto de luz
	var distance = light_node.position.distance_to(self.position);
	var d = distance / 1000;
	var opacity = 1 - lerp(shadow_min_value, shadow_max_value, d);

	# Pasamos parámetros al "shader"
	sprite.material.set("shader_parameter/deform", deform)
	sprite.material.set("shader_parameter/opacity", opacity)
	sprite.material.set("shader_parameter/offset", offset)
	sprite.material.set("shader_parameter/flipY", not character_is_over_light)


# Para definir si el personaje está activo o no
# Si no está activo, no se podrá mover ni interactuar con el
func set_character_active(active: bool):
	_character_active = active
	if not active:
		# Si desactivamos el personaje, también desactivamos el "pathfinding"
		_path_finding_moving = false


# Función que activa items que el personaje puede vestir (como lentes, sombrero, etc)
# Se añaden los items a un "listado de items activos", que luego por la función "process_dress_item"
# se mostrarán en el personaje principal
func dress_item(_name: String, active: bool):
	var child = clothes.find_child(_name)
	if not child:
		return # Si no existe el nodo, solo terminamos la función

	# Buscamos si ya existe el item en el listado de items activos
	var index = _dress_item_list.find(_name) 
	var exists = index >= 0
	
	if active:
		if not exists:
			# Agregamos el item a "activo", si todavía no existe, y la variable "active" es verdadera
			_dress_item_list.append(_name)
	else:
		if exists:
			# Quitamos el item de "activo", si existe como activo y la variable "active" es falsa
			_dress_item_list.remove_at(index)


# Retorna el listado de items que está "vistiendo" el personaje principal
func get_dress_item_list():
	return _dress_item_list
