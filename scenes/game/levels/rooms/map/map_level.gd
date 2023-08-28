extends TextureRect
## Clase que controla cada elemento del mapa principal 
## 
## Escucha eventos de ratón, valida que elemento fue presionado, hace redirect a otra escena, activa diferente estatuses de elementos del mapa 

# DOCUMENTACIÓN CREAR UN MAPA GENERAL: https://docs.google.com/document/d/1q-aOyPNZ2Ldn6hH9H43Ym6u_fmWvujVgbkHfayPDN-E

var active = "" # Estado del elemento clicqueado
var blocked = true # Estado del elemento del mapa (activado /descativado)


# Función que se llama cuando la escena esta cargada
func _ready():
	# habilitamos procesado de input 
	set_process_input(true)
	# habilitamos y deshabilitamos elementos en el mapa
	set_level_status()
	# conectamos el evento _mouse_entered
	self.mouse_entered.connect(_mouse_entered)
	# conectamos el evento _mouse_exited
	self.mouse_exited.connect(_mouse_exited)


# Función que escucha el teclado y raton
func _input(event):
	# escuchamos el evento del boton de raton
	if event is InputEventMouseButton:
		# Validamos si se preciono el boton izquierdo del mouse
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Llamamos la funcion del click
			on_click()


# Funcion que escucha
func on_click():
	# Validamos si se presionó el elemneto del mapa
	if active:
		# Validamos si el elemneto del mapa tiene el nombre Antigua
		if name == "Antigua":
			# Cargamos la escena de la iglesia
			SceneTransition.change_scene("res://Scenes/Church/ChurchInterior.tscn")
		# Validamos si el elemneto del mapa tiene el nombre Tikal
		elif name == "Tikal":
			# Cargamos la escena de tikal
			SceneTransition.change_scene("res://Scenes/Tikal/TikalInterior.tscn")
		# Validamos si el elemneto del mapa tiene el nombre Panajachel
		elif name == "Panajachel":
			# Cargamos la escena de la casa maya
			SceneTransition.change_scene("res://Scene1.tscn")


# Función que se llama cuando el raton entra a una area predefinida
func _mouse_entered():
	# Seteamos el estado como cliqueado si el elemento no esta bloqueado
	if !blocked:
		active = name


# Función que se llama cuando el raton sale de una area predefinida
func _mouse_exited():
	# Quitamos el estado cliqueado
	active = ""


#Seteamos estados de puntos de entradas a escenas
func set_level_status():
	#Cargamos el progreso del juego
	var data = SaveProgress.load_game()
	#Validamos si hay escenas activas guardadas
	if (data && data.size() && data.activeScene && data.activeScene.size()):
		#Recorremos cada escena activa
		for i in data.activeScene.size():
			#Validamos si la escena activa es la nuestra
			if data.activeScene[i] == name:
				#Desbloqueamos la escena
				blocked = false
				#Aplicamos el shader del estilo habilitado
				self.material.shader = load("res://scenes/game/levels/animations/map/element_active.gdshader")
				#Obtenemos el nodo Luz
				var light = get_tree().get_current_scene().get_node(name + 'Light2D')
				#Habilitamos luz
				light.visible = true
	# Validamos si la escena es la principal
	elif  name == 'Panajachel':
		#Desbloqueamos la escena
		blocked = false
		#Aplicamos el shader del estilo habilitado
		self.material.shader = load("res://scenes/game/levels/animations/map/element_active.gdshader")
