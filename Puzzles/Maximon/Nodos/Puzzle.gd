extends Node2D

# DOCUMENTACIÓN (maximón): https://docs.google.com/document/d/1szQIv2aEz_EdoMq34ml8DG-lRju3irkkjRO4QXsDRWc/edit#heading=h.e2j6ax5ma83s

# Canvas principal
@onready var canvas = $"../.."

# Textos a mostrar en el puzzle y nodo que mostrará el texto
@export var TextoInstrucciones = "Coloca los objetos en el orden correcto. Un objeto se mueve haciendo clic sobre él. Solo se puede mover hacia un espacio vacío."
@export var TextoObjetoNoMovido = "El objeto no se puede mover."
@export var TextoObjetoMovido = "Objeto movido."
@export var TextoObjetoMovidoIncorrecto = "Esa no parece ser la posición correcta."
@export var TextoObjetoMovidoCorrecto1 = "Perfecto, sigue así." # 1 a 2 elementos correctos
@export var TextoObjetoMovidoCorrecto2 = "Cada vez más cerca." # 3 elementos correctos
@export var TextoObjetoMovidoCorrecto3 = "Ya casi lo tienes, ¡un paso más!." # 4 elementos correctos
@export var TextoJuegoFinalizado = "Perfecto, has colocado los objetos de forma correcta. Sigue la puerta y encontrarás lo que buscas." # 5 elementos correctos
@onready var Mensaje = $"../../Messages"

# Variables de las imágenes que se tienen que mover y ajustar
@onready var SpriteVelaRoja = $Background/Objects/VelaRoja
@onready var SpriteVelaCeleste = $Background/Objects/VelaCeleste
@onready var SpriteVelaAzul = $Background/Objects/VelaAzul
@onready var SpriteCigarro = $Background/Objects/Cigarro
@onready var SpriteSombrero = $Background/Objects/Sombrero
@onready var Objetos = $Background/Objects

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
var position_objects_map_2 = {
	"AreaSombrero": "",
	"AreaVelaRoja": "VelaRoja",
	"AreaVelaCeleste": "VelaCeleste",
	"AreaVelaAzul": "VelaAzul",
	"AreaCigarro": "Cigarro",
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
	save_objects_position()
	add_area_events()
	Mensaje.text = TextoInstrucciones
	mess_objects()

# Función que dectecta eventos del teclado y ratón
func _unhandled_input(event: InputEvent):
	print("algo")
	if !puzzle_active:
		return # Si el juego no está activo, terminamo la función
	# Cuando damos clic, validamos que estamos en un área jugable, y que no sea un área vacía
	if event.is_action_pressed("click"):
		
		Mensaje.text = TextoInstrucciones
		if area_active:
			move_object()

# Añade los eventos de entrar/salir de las áreas jugables
func add_area_events():
	for sprite in [ SpriteVelaRoja, SpriteVelaCeleste, SpriteVelaAzul, SpriteCigarro, SpriteSombrero ]:
		var area = sprite.find_child("Area2D")
		var name = "Area" + sprite.name
		area.mouse_entered.connect(mouse_entered.bind(name))
		area.mouse_exited.connect(mouse_exited)

# Función de asigna un área activa
func mouse_entered(name: String):
	area_active = name

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
		print("Se movió el objeto (" + object_name + ") hacia (" + area_available + ")")
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
				print("Movido correctamente: ", correct_count)
			else:
				m = m + " " + TextoObjetoMovidoIncorrecto
				print("Movido IN-correctamente")
				Mensaje.text = m
	else:
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
func get_content_area_object(name: String):
	for area_name in position_objects_map:
		if position_objects_map[area_name] == name:
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

# Acción de ocultar el puzzle, al presionar el botón de cerrar
func _on_close_button_pressed():
	canvas.visible = false
