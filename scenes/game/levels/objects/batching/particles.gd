extends Node2D
## Clase que genera múltiples Mallas (Meshes)
## 
## Genera múltiples mallas en el nodo Multimesh

@export var distribute_on_ready = false

# Declaramos nodos
@onready var _mesh_instance = $Icon
@onready var _multi_mesh_instance = $MultiMeshInstance2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Llamamos la función que desordena las imagenes
	_do_distribution()


func _do_distribution():
	# Obtenemos el mesh de multimesh instancia
	var multi_mesh = _multi_mesh_instance.multimesh
	# Copiamos el mesh del icono
	multi_mesh.mesh = _mesh_instance.mesh
	# Obtenemos el tamaño de view port
	var screen_size = get_viewport_rect().size
	# Recorremos la cantidad de instancias seteadas
	for i in multi_mesh.instance_count:
		# Creamos el vector
		var v = Vector2( randf() * screen_size.x, randf() * screen_size.y )
		# Creamos la transformación
		var t = Transform2D(0.0, v)
		# Seteamos la transformación
		multi_mesh.set_instance_transform_2d(i, t)
		# Seteamos el color
		multi_mesh.set_instance_color(i, Color.from_hsv(randf(), randf(), max(randf(), .4), 1.0))
