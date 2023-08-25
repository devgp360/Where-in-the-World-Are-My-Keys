extends TextureRect
## Clase que controla la celda de la tabla de avance guardado
##
## Cambia el efecto hover de la celda, activa los botones eliminar y cargar, resetea la celda a su estado inicial

# DOCUMENTACIÓN SISTEMA AVANZADO DE GUARDADO DE PROGRESO EN EL JUEGO: https://docs.google.com/document/d/1XBbo4V4ioPuR-yhDVmgYflzPj1b3mM7mUP7ZjaXqUUs

#Declaramos el estado del elemento del grid
var selected = false

#Declaramos la ruta del estado a cargar
@export var scenePath : String
#Declaramos el nodo del padre
@export var parent : Node2D
#Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	#Validamos si no esta sseleccionado el elemento
	if !selected:
		#Ajustamos la transparencia
		modulate.a8=200


func _on_mouse_exited():
	print("aqu")
	#Validamos si no esta sseleccionado el elemento
	if !selected:
		#Ajustamos la transparencia
		modulate.a8=255


func _on_pressed():
	#Llamamos la funcion que resetea los estados
	parent.clear()
	#Seteamos el estado como seleccionado
	selected = true
	#Ajustamos la transparencia
	modulate.a8=150
	parent.removeButton.visible = true
	parent.loadButton.visible = true
	
func reset():
	#Seteamos el estado como no seleccionado
	selected = false
	#Ajustamos la transparencia
	modulate.a8=255
