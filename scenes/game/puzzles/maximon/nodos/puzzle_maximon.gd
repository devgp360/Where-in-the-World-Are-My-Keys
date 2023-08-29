extends Node2D
## Clase que controla el rompecabezas de Maximón 
## 
## Define los elementos del rompecabezas (colores, posiciones, etc), controla los movimientos de objetos, valida las posibilidades de mover los objetos, muestra pistas 
## Cuenta elementos puestos en forma correcta, cierra el rompecabezas


# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s
# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link

# Señal que se ejecutará cuando se termine el juego
signal ended_game()

# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc
# Referencia al personaje principal
@export var character: CharacterBody2D
# Textos a mostrar en el puzzle y nodo que mostrará el texto
@export var TextoInstrucciones = "Coloca los objetos en el orden correcto. Un objeto se mueve haciendo clic sobre él. Solo se puede mover hacia un espacio vacío."
@export var TextoObjetoNoMovido = "El objeto no se puede mover."
@export var TextoObjetoMovido = "Objeto movido."
@export var TextoObjetoMovidoIncorrecto = "Esa no parece ser la posición correcta."
@export var TextoObjetoMovidoCorrecto1 = "Perfecto, sigue así." # 1 a 2 elementos correctos
@export var TextoObjetoMovidoCorrecto2 = "Cada vez más cerca." # 3 elementos correctos
@export var TextoObjetoMovidoCorrecto3 = "Ya casi lo tienes, ¡un paso más!." # 4 elementos correctos
@export var TextoJuegoFinalizado = "Perfecto, has colocado los objetos en orden correcto. Sigue la puerta y encontrarás respuestas." # 5 elementos correctos

# Si el juego está activo, se podrán mover objetos
var _puzzle_active = true

# Las áreas están relacionadas hacia otras áreas, donde se podrá mover un objeto
# Relación de áreas entre sí, para saber hacia qué areas se puede mover un objeto
var _area_moving_map = {
	"AreaAuxiliar": ["AreaVelaRoja", "AreaSombrero", "AreaCigarro"],
	"AreaSombrero": ["AreaAuxiliar", "AreaCigarro"],
	"AreaCigarro": ["AreaSombrero", "AreaAuxiliar", "AreaVelaCeleste", "AreaVelaAzul"],
	"AreaVelaRoja": ["AreaAuxiliar", "AreaVelaCeleste"],
	"AreaVelaCeleste": ["AreaVelaRoja", "AreaVelaAzul", "AreaCigarro"],
	"AreaVelaAzul": ["AreaVelaCeleste", "AreaCigarro"],
}

# Posición de los objetos (un objeto está siempre en un area)
# Este objeto lo usamos para colocar los objetos al iniciar el puzzle (en este caso en lugares incorrectos)
var _position_objects_map = {
	"AreaSombrero": "Cigarro",
	"AreaVelaRoja": "VelaAzul",
	"AreaVelaCeleste": "",
	"AreaVelaAzul": "VelaRoja",
	"AreaCigarro": "VelaCeleste",
	"AreaAuxiliar": "Sombrero",
}

# Guarda las posiciones iniciales de cada objeto
var _real_objects_position = {
	"Sombrero": Vector2(0, 0),
	"VelaRoja": Vector2(0, 0),
	"VelaCeleste": Vector2(0, 0),
	"VelaAzul": Vector2(0, 0),
	"Cigarro": Vector2(0, 0),
	"Auxiliar": Vector2(-238.823, 4.706),
}

# Area activa: es la que tiene el puntero del mouse sobre ella
var _area_active = ""
# Area que está disponible para mover un objeto hacia dicha área. Se inicializa en base a: position_objects_map
var _area_available = ""

# Variables de las imágenes que se tienen que mover y ajustar
@onready var canvas = $CanvasLayer # Canvas principal
@onready var SpriteVelaRoja = $CanvasLayer/Background/Objects/VelaRoja
@onready var SpriteVelaCeleste = $CanvasLayer/Background/Objects/VelaCeleste
@onready var SpriteVelaAzul = $CanvasLayer/Background/Objects/VelaAzul
@onready var SpriteCigarro = $CanvasLayer/Background/Objects/Cigarro
@onready var SpriteSombrero = $CanvasLayer/Background/Objects/Sombrero
@onready var Objetos = $CanvasLayer/Background/Objects
@onready var Mensaje = $CanvasLayer/Messages


# Función de inicialización
func _ready():
	_save_objects_position() # Guardamos las posiciones iniciales de los objetos
	_add_area_events() # Agregamos eventos para poder mover los objetos
	Mensaje.text = TextoInstrucciones # Colocamos el texto inicial de instrucciones
	_mess_objects() # Desordenamos los objetos


# Función que dectecta eventos del teclado y ratón
func _unhandled_input(event: InputEvent):
	if not _puzzle_active:
		return # Si el juego no está activo, terminamo la función
	# Cuando damos clic, validamos que estamos en un área jugable, y que no sea un área vacía
	if event.is_action_pressed("click"):
		Mensaje.text = TextoInstrucciones # Si se da clic en una área vacía, mostramos las instrucciones
		if _area_active: # Si estamos sobre un objeto (y le dimos clic), procedemos a moverlo
			_move_object()


# Añade los eventos de entrar/salir de las áreas jugables
func _add_area_events():
	for sprite in [ SpriteVelaRoja, SpriteVelaCeleste, SpriteVelaAzul, SpriteCigarro, SpriteSombrero ]:
		# Recorremos cada objeto y buscamos su área de colisión
		var area = sprite.find_child("Area2D")
		var _name = "Area" + sprite.name
		# Luego añadimos los eventos de entrar/salir para el cursor
		area.mouse_entered.connect(_mouse_entered.bind(_name))
		area.mouse_exited.connect(_mouse_exited)


# Función que asigna un área activa (para saber a que objeto dimos clic)
func _mouse_entered(_name: String):
	_area_active = _name


# Función que desasigna un área activa
func _mouse_exited():
	_area_active = ""


func _move_object():
	# Nombre del objeto a mover (Ej: Sombrero)
	var _object_name = _area_active.replace("Area", "")
	# Nombre del área donde se encuentra el objeto a mover (Ej: AreaAuxiliar)
	var _object_area_name = _get_content_area_object(_object_name)
	# Areas a donde podría ser movido el objeto que se quiere mover
	var _areas = _area_moving_map[_object_area_name]
	# Validamos si el objeto se puede mover, según el area que esté disponible
	if _areas.find(_area_available) >= 0:
		# Posición a la cual se moverá el objeto
		var _destination_position = _real_objects_position[_area_available.replace("Area", "")]
		# Sprite que se le cambiará su posición
		var _object_to_move: Sprite2D = Objetos.find_child(_object_name)
		# Actualizamos la posición del objeto a mover
		_object_to_move.position = _destination_position
		# El área donde estaba el objeto la dejamos vacía
		_position_objects_map[_object_area_name] = ""
		# Actualizamos el objeto que acabamos de mover, a su nueva área contenedora
		_position_objects_map[_area_available] = _object_name
		# Validamos si el objeto se movió correctamente
		var _is_correct = _area_available == "Area" + _object_name
		# Reasignamos la nueva area disponible
		_area_available = _object_area_name
		# Mensaje general a mostrar cuando se movió un objeto
		var m = TextoObjetoMovido
		
		# Cuando resolvemos el puzzle, ponemos mensaje final y desactivamos el puzzle
		if _is_game_ended():
			Mensaje.text = TextoJuegoFinalizado
			_puzzle_active = false
			self.emit_signal("ended_game")
			return
		else:
			if _is_correct:
				# En caso se mueva una pieza de forma correcta, se muestra un mensaje positivo
				var _correct_count = _get_correct_count()
				if _correct_count == 1 || _correct_count == 2:
					m = m + " " + TextoObjetoMovidoCorrecto1
				elif _correct_count == 3:
					m = m + " " + TextoObjetoMovidoCorrecto2
				elif _correct_count == 4:
					m = m + " " + TextoObjetoMovidoCorrecto3
				Mensaje.text = m
			else:
				m = m + " " + TextoObjetoMovidoIncorrecto
				Mensaje.text = m
	else:
		# Si no se pudo mover el objeto, mostramos el mensaje correspondiente
		Mensaje.text = TextoObjetoNoMovido


# Función que guarda las posiciones iniciales de cada objeto. Estas posiciones son las correctas
func _save_objects_position():
	_real_objects_position["VelaRoja"] = SpriteVelaRoja.position
	_real_objects_position["VelaCeleste"] = SpriteVelaCeleste.position
	_real_objects_position["VelaAzul"] = SpriteVelaAzul.position
	_real_objects_position["Cigarro"] = SpriteCigarro.position
	_real_objects_position["Sombrero"] = SpriteSombrero.position


# Esta función desordena los objetos del puzzle y los pone en posiciones incorrectas
func _mess_objects():
	for _area_name in _position_objects_map:
		var _object_name = _position_objects_map[_area_name]
		if _object_name:
			# Si hay un nombre de objeto, buscamos el sprite y le colocamos su nueva posición
			var _sprite: Sprite2D = Objetos.find_child(_object_name)
			_sprite.position = _real_objects_position[_area_name.replace("Area", "")]
		else:
			# Cuando no hay nombre de objeto, quiere decir que esa área, será la que está disponible
			_area_available = _area_name


# Busca en qué area se encuentra un objeto. Por ejemplo el objeto "Sombrero" se puede encontrar
# en el área llamada "AreaAuxiliar"
func _get_content_area_object(_name: String):
	for _area_name in _position_objects_map:
		if _position_objects_map[_area_name] == _name:
			return _area_name
	return ""


# Valida si el puzzle ya está resuelto
func _is_game_ended():
	var _all_correct = _get_correct_count()
	return _all_correct == 5


# Retorna el número de elementos puestos de forma correcta
func _get_correct_count():
	var _all_correct = 0
	for _area_name in _position_objects_map:
		var _current_object = _position_objects_map[_area_name]
		var _correct_object = _area_name.replace("Area", "")
		if _area_name != "AreaAuxiliar":
			if _current_object == _correct_object:
				_all_correct = _all_correct + 1
	return _all_correct


# Muestra/oculta el puzzle
func _set_visible(_visible: bool):
	canvas.visible = _visible
	character.set_character_active(not _visible)


# Acción de ocultar el puzzle, al presionar el botón de cerrar
func _on_close_button_pressed():
	_set_visible(false)


# Añade un evento para escuchar cuando el puzzle esté finalizado
func add_ended_game(fn):
	ended_game.connect(fn)
