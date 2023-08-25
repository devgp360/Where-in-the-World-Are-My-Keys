extends Node2D

# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s
# DOCUMENTACIÓN (áreas de colisión): https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw/edit?usp=drive_link

# Canvas principal
@onready var canvas = $CanvasLayer
# Referencia al personaje principal
@export var character: CharacterBody2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Textos a mostrar en el puzzle y nodo que mostrará el texto
@export var TextoInstrucciones = "Coloca los objetos en el orden correcto. Un objeto se mueve haciendo clic sobre él. Solo se puede mover hacia un espacio vacío."
@export var TextoObjetoNoMovido = "El objeto no se puede mover."
@export var TextoObjetoMovido = "Objeto movido."
@export var TextoObjetoMovidoIncorrecto = "Esa no parece ser la posición correcta."
@export var TextoObjetoMovidoCorrecto1 = "Perfecto, sigue así." # 1 a 2 elementos correctos
@export var TextoObjetoMovidoCorrecto2 = "Cada vez más cerca." # 3 elementos correctos
@export var TextoObjetoMovidoCorrecto3 = "Ya casi lo tienes, ¡un paso más!." # 4 elementos correctos
@export var TextoJuegoFinalizado = "Perfecto, has colocado los objetos en orden correcto. Sigue la puerta y encontrarás respuestas." # 5 elementos correctos
@onready var Mensaje = $CanvasLayer/Messages

# Variables de las imágenes que se tienen que mover y ajustar
@onready var SpriteVelaRoja = $CanvasLayer/Background/Objects/VelaRoja
@onready var SpriteVelaCeleste = $CanvasLayer/Background/Objects/VelaCeleste
@onready var SpriteVelaAzul = $CanvasLayer/Background/Objects/VelaAzul
@onready var SpriteCigarro = $CanvasLayer/Background/Objects/Cigarro
@onready var SpriteSombrero = $CanvasLayer/Background/Objects/Sombrero
@onready var Objetos = $CanvasLayer/Background/Objects

# Señal que se ejecutará cuando se termine el juego
signal ended_game()

# Si el juego está activo, se podrán mover objetos
var puzzle_active = true

# Las áreas están relacionadas hacia otras áreas, donde se podrá mover un objeto
# Relación de áreas entre sí, para saber hacia qué areas se puede mover un objeto
var area_moving_map = {
	"AreaAuxiliar": ["AreaVelaRoja", "AreaSombrero", "AreaCigarro"],
	"AreaSombrero": ["AreaAuxiliar", "AreaCigarro"],
	"AreaCigarro": ["AreaSombrero", "AreaAuxiliar", "AreaVelaCeleste", "AreaVelaAzul"],
	"AreaVelaRoja": ["AreaAuxiliar", "AreaVelaCeleste"],
	"AreaVelaCeleste": ["AreaVelaRoja", "AreaVelaAzul", "AreaCigarro"],
	"AreaVelaAzul": ["AreaVelaCeleste", "AreaCigarro"],
}
# Posición de los objetos (un objeto está siempre en un area)
# Este objeto lo usamos para colocar los objetos al iniciar el puzzle (en este caso en lugares incorrectos)
var position_objects_map = {
	"AreaSombrero": "Cigarro",
	"AreaVelaRoja": "VelaAzul",
	"AreaVelaCeleste": "",
	"AreaVelaAzul": "VelaRoja",
	"AreaCigarro": "VelaCeleste",
	"AreaAuxiliar": "Sombrero",
}
# Guarda las posiciones iniciales de cada objeto
var real_objects_position = {
	"Sombrero": Vector2(0, 0),
	"VelaRoja": Vector2(0, 0),
	"VelaCeleste": Vector2(0, 0),
	"VelaAzul": Vector2(0, 0),
	"Cigarro": Vector2(0, 0),
	"Auxiliar": Vector2(-238.823, 4.706),
}

# Area activa: es la que tiene el puntero del mouse sobre ella
var area_active = ""
# Area que está disponible para mover un objeto hacia dicha área. Se inicializa en base a: position_objects_map
var area_available = ""

# Función de inicialización
func _ready():
	save_objects_position() # Guardamos las posiciones iniciales de los objetos
	add_area_events() # Agregamos eventos para poder mover los objetos
	Mensaje.text = TextoInstrucciones # Colocamos el texto inicial de instrucciones
	mess_objects() # Desordenamos los objetos

# Función que dectecta eventos del teclado y ratón
func _unhandled_input(event: InputEvent):
	if !puzzle_active:
		return # Si el juego no está activo, terminamo la función
	# Cuando damos clic, validamos que estamos en un área jugable, y que no sea un área vacía
	if event.is_action_pressed("click"):
		Mensaje.text = TextoInstrucciones # Si se da clic en una área vacía, mostramos las instrucciones
		if area_active: # Si estamos sobre un objeto (y le dimos clic), procedemos a moverlo
			move_object()

# Añade los eventos de entrar/salir de las áreas jugables
func add_area_events():
	for sprite in [ SpriteVelaRoja, SpriteVelaCeleste, SpriteVelaAzul, SpriteCigarro, SpriteSombrero ]:
		# Recorremos cada objeto y buscamos su área de colisión
		var area = sprite.find_child("Area2D")
		var _name = "Area" + sprite.name
		# Luego añadimos los eventos de entrar/salir para el cursor
		area.mouse_entered.connect(mouse_entered.bind(_name))
		area.mouse_exited.connect(mouse_exited)

# Función que asigna un área activa (para saber a que objeto dimos clic)
func mouse_entered(_name: String):
	area_active = _name

# Función que desasigna un área activa
func mouse_exited():
	area_active = ""

func move_object():
	# Nombre del objeto a mover (Ej: Sombrero)
	var object_name = area_active.replace("Area", "")
	# Nombre del área donde se encuentra el objeto a mover (Ej: AreaAuxiliar)
	var object_area_name = get_content_area_object(object_name)
	# Areas a donde podría ser movido el objeto que se quiere mover
	var areas = area_moving_map[object_area_name]
	# Validamos si el objeto se puede mover, según el area que esté disponible
	if areas.find(area_available) >= 0:
		# Posición a la cual se moverá el objeto
		var destination_position = real_objects_position[area_available.replace("Area", "")]
		# Sprite que se le cambiará su posición
		var object_to_move: Sprite2D = Objetos.find_child(object_name)
		# Actualizamos la posición del objeto a mover
		object_to_move.position = destination_position
		# El área donde estaba el objeto la dejamos vacía
		position_objects_map[object_area_name] = ""
		# Actualizamos el objeto que acabamos de mover, a su nueva área contenedora
		position_objects_map[area_available] = object_name
		# Validamos si el objeto se movió correctamente
		var is_correct = area_available == "Area" + object_name
		# Reasignamos la nueva area disponible
		area_available = object_area_name
		# Mensaje general a mostrar cuando se movió un objeto
		var m = TextoObjetoMovido
		
		# Cuando resolvemos el puzzle, ponemos mensaje final y desactivamos el puzzle
		if is_game_ended():
			Mensaje.text = TextoJuegoFinalizado
			puzzle_active = false
			self.emit_signal("ended_game")
			return
		else:
			if is_correct:
				# En caso se mueva una pieza de forma correcta, se muestra un mensaje positivo
				var correct_count = get_correct_count()
				if correct_count == 1 || correct_count == 2:
					m = m + " " + TextoObjetoMovidoCorrecto1
				elif correct_count == 3:
					m = m + " " + TextoObjetoMovidoCorrecto2
				elif correct_count == 4:
					m = m + " " + TextoObjetoMovidoCorrecto3
				Mensaje.text = m
			else:
				m = m + " " + TextoObjetoMovidoIncorrecto
				Mensaje.text = m
	else:
		# Si no se pudo mover el objeto, mostramos el mensaje correspondiente
		Mensaje.text = TextoObjetoNoMovido

# Función que guarda las posiciones iniciales de cada objeto. Estas posiciones son las correctas
func save_objects_position():
	real_objects_position["VelaRoja"] = SpriteVelaRoja.position
	real_objects_position["VelaCeleste"] = SpriteVelaCeleste.position
	real_objects_position["VelaAzul"] = SpriteVelaAzul.position
	real_objects_position["Cigarro"] = SpriteCigarro.position
	real_objects_position["Sombrero"] = SpriteSombrero.position

# Esta función desordena los objetos del puzzle y los pone en posiciones incorrectas
func mess_objects():
	for area_name in position_objects_map:
		var object_name = position_objects_map[area_name]
		if object_name:
			# Si hay un nombre de objeto, buscamos el sprite y le colocamos su nueva posición
			var sprite: Sprite2D = Objetos.find_child(object_name)
			sprite.position = real_objects_position[area_name.replace("Area", "")]
		else:
			# Cuando no hay nombre de objeto, quiere decir que esa área, será la que está disponible
			area_available = area_name

# Busca en qué area se encuentra un objeto. Por ejemplo el objeto "Sombrero" se puede encontrar
# en el área llamada "AreaAuxiliar"
func get_content_area_object(_name: String):
	for area_name in position_objects_map:
		if position_objects_map[area_name] == _name:
			return area_name
	return ""

# Valida si el puzzle ya está resuelto
func is_game_ended():
	var all_correct = get_correct_count()
	return all_correct == 5

# Retorna el número de elementos puestos de forma correcta
func get_correct_count():
	var all_correct = 0
	for area_name in position_objects_map:
		var current_object = position_objects_map[area_name]
		var correct_object = area_name.replace("Area", "")
		if area_name != "AreaAuxiliar":
			if current_object == correct_object:
				all_correct = all_correct + 1
	return all_correct

# Muestra/oculta el puzzle
func _set_visible(_visible: bool):
	canvas.visible = _visible
	character.set_character_active(!_visible)

# Acción de ocultar el puzzle, al presionar el botón de cerrar
func _on_close_button_pressed():
	_set_visible(false)

# Añade un evento para escuchar cuando el puzzle esté finalizado
func add_ended_game(fn):
	ended_game.connect(fn)
