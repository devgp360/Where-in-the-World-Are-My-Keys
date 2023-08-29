extends TextureRect
## Clase que controla cada elemento del mapa principal 
## 
## Escucha eventos de ratón, valida que elemento fue presionado, hace redirect a otra escena, activa diferente estatuses de elementos del mapa 

# DOCUMENTACIÓN CREAR UN MAPA GENERAL: https://docs.google.com/document/d/1q-aOyPNZ2Ldn6hH9H43Ym6u_fmWvujVgbkHfayPDN-E

# Rutas a shaders de elemento activo
const BASE_PATH_ANIM = "res://scenes/game/levels/animations/map/";
const PATH_SHADER_ACTIVE = BASE_PATH_ANIM + "element_active.gdshader";
# Rutas de las escenas para carga
const BASE_PATH_SCENE = "res://scenes/game/levels/rooms/";

var _active = "" # Estado del elemento clicqueado
var _blocked = true # Estado del elemento del mapa (activado /descativado)
# Rutas de las escenas del mapa principal
var _scene_paths = {
	"Antigua": BASE_PATH_SCENE + "church/church_interior.tscn",
	"Tikal": BASE_PATH_SCENE + "tikal/tikal_interior.tscn",
	"Panajachel": BASE_PATH_SCENE + "scene_1/scene_1.tscn",
}


# Función que se llama cuando la escena esta cargada
func _ready():
	# Habilitamos procesado de input 
	set_process_input(true)
	# Habilitamos y deshabilitamos elementos en el mapa
	_set_level_status()
	# Conectamos el evento _mouse_entered
	self.mouse_entered.connect(_mouse_entered)
	# Conectamos el evento _mouse_exited
	self.mouse_exited.connect(_mouse_exited)


# Función que escucha el teclado y raton
func _input(event):
	# Escuchamos el evento del boton de raton
	if event is InputEventMouseButton:
		# Validamos si se preciono el boton izquierdo del mouse
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Llamamos la funcion del click
			_load_escene()


# Función que se llama cuando el raton entra a una area predefinida
func _mouse_entered():
	# Seteamos el estado como cliqueado si el elemento no esta bloqueado
	if not _blocked:
		_active = name


# Función que se llama cuando el raton sale de una area predefinida
func _mouse_exited():
	# Quitamos el estado cliqueado
	_active = ""


# Función que cargará una escena, dependiendo del elemento al que se dió clic en el mapa
func _load_escene():
	# Validamos si se presionó el elemento del mapa y si la ruta a la escena existe
	if _active and _scene_paths.has(name):
		var path = _scene_paths[name] # Cargamos la ruta de la escena
		SceneTransition.change_scene(path) # Cargamos la escena


# Seteamos estados de puntos de entradas a escenas
func _set_level_status():
	# Cargamos el progreso del juego
	var data = SaveProgress.load_game()
	# Validamos si hay escenas activas guardadas
	if data and data.size() and data.activeScene and data.activeScene.size():
		# Recorremos cada escena activa
		for i in data.activeScene.size():
			# Validamos si la escena activa es la nuestra
			if data.activeScene[i] == name:
				# Desbloqueamos la escena
				_blocked = false
				# Aplicamos el shader del estilo habilitado
				self.material.shader = load(PATH_SHADER_ACTIVE)
				# Obtenemos el nodo Luz
				var light = get_tree().get_current_scene().get_node(name + 'Light2D')
				# Habilitamos luz
				light.visible = true
	# Validamos si la escena es la principal
	elif  name == 'Panajachel':
		# Desbloqueamos la escena
		_blocked = false
		# Aplicamos el shader del estilo habilitado
		self.material.shader = load(PATH_SHADER_ACTIVE)
