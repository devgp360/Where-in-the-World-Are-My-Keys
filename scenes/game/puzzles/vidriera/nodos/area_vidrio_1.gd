extends Area2D

# DOCUMENTACIÓN: https://docs.google.com/document/d/1wEfx7wOw5FJ0GpRLCWUPQObmkE-fCed8TOZk5ZRGOyU/edit#heading=h.e2j6ax5ma83s

@export var canvas: CanvasLayer
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

var active = "" # Indica si el ítem está activo o no


# Función de inicialización
func _ready():
	set_process_input(true)
	# DOCUMENTACIÓN (señales): https://docs.google.com/document/d/1bbroyXp11L4_FpHpqA-RckvFLRv3UOE-hmQdwtx27eo/edit?usp=drive_link
	self.mouse_entered.connect(_mouse_entered) # Evento cuando el mouse 
	self.mouse_exited.connect(_mouse_exited) # Evento de  el puntero del mouse


# Función para leer eventos del ratón
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_click() # Detectar clic


# Activar fragmento
func _mouse_entered():
	active = name


# Desactivar fragmento
func _mouse_exited():
	active = ""


# Al dar clic en un área de un fragmento de vidrio
func on_click():
	if active:
		canvas._click_event(name)
