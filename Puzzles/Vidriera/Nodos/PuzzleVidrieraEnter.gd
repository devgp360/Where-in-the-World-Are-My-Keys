extends Area2D

@export var puzzle: CanvasLayer # Canvas principal del puzzle
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

var is_character_entered = false # Indica si el personaje entró en contacto con el área

# Función de inicialización
func _ready():
	# Agregamos los eventos: entrar/salir del área de colisión
	self.area_entered.connect(_area_entered)
	self.area_exited.connect(_area_exited)
	self.input_event.connect(_input_event)

# Al entrar al objeto que muestra un el puzzle
func _area_entered(area: Area2D):
	if area.name == 'mainchar_area':
		is_character_entered = true

# Al salir al objeto que muestra un el puzzle
func _area_exited(area: Area2D):
	if area.name == 'mainchar_area':
		is_character_entered = false

# Mostra el puzzle al dar clic en el objeto que muestra el puzzle (en este caso una ventana)
func _input_event(v, e: InputEvent, i):
	if e.is_action_pressed("click") and is_character_entered:
		puzzle._set_visible(true)
