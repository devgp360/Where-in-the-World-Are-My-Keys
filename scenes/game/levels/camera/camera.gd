extends Camera2D
## Clase que controla Camara principal
##
## Se realizan los calculos de posiciones para definir si hay que mover la camara hacia el personaje principal

# DOCUMENTACIÓN SOBRE CREACIÓN DE CÁMARAS Y CONFIGURACIÓN DE SU MOVIMIENTO: https://docs.google.com/document/d/1d4RoDe9aK4ortBhJ1grTUOdpXnICxBa7fl_vty2OF-w

# DOCUMANTACIÓN (cámaras): https://docs.google.com/document/d/1d4RoDe9aK4ortBhJ1grTUOdpXnICxBa7fl_vty2OF-w/edit?usp=drive_link

# Variable para tener referencia del personaje principal
@export var character: CharacterBody2D
# Puedes leer más sobre nodos en éste documento: https://docs.google.com/document/d/1AiO1cmB31FSQ28me-Rb15EQni8Pyomc1Vgdm1ljL3hc


# Función de inicialización
func _ready():
	# Agregar la posición de la cámara, al centro de la pantalla
	position = global_transform.origin


# Llamado a cada 'frame'. 'delta' es el tiempo transcurrido desde el 'frame' anterior.
func _process(_delta):
	var charpos = character.position # Posición del personaje
	var viewport_size = get_viewport_rect().size # Tamaño de la pantalla
	var viewport_half = viewport_size * 0.5 # Mitad del tamaño de la pantalla
	var campos = viewport_half; # Variable para guardar la posición de la cámara
	
	# Posición de la cámara, calculando la mitad del tamaño de la pantalla
	# para no mover siempre la cámara, sino que cuando se mueva el personaje hacia la mitad de la pantalla
	campos.x = campos.x + position.x;
	campos.y = campos.y + position.y;

	# Si la posición del personaje es diferente de la posición de la cámara (en el eje X)
	if charpos.x < (campos.x) || charpos.x > (campos.x):
		position.x = charpos.x # Se actualiza la posición de la cámara con la posición del personaje

	# Si la posición del personaje es diferente de la posición de la cámara (en el eje Y)
	if charpos.y < (campos.y) || charpos.y > (campos.y):
		position.y = charpos.y # Se actualiza la posición de la cámara con la posición del personaje
