extends Area2D

@export var canvas: CanvasLayer
var active = ""

# Función de inicialización
func _ready():
	set_process_input(true)
	self.mouse_entered.connect(_mouse_entered) # Evento cuando el mouse 
	self.mouse_exited.connect(_mouse_exited) # Evento de  el puntero del mouse

# Función para leer eventos del ratón
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_click() # Detectar clic

# Al dar clic en un área de un fragmento de vidrio
func on_click():
	if active:
		canvas._click_event(name)

# Activar fragmento
func _mouse_entered():
	active = name

# Desactivar fragmento
func _mouse_exited():
	active = ""
