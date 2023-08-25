extends Node2D

# DOCUMENTACIÓN (culling): https://docs.google.com/document/d/1oX77HHdm_DiiigEn7OBe9BDAFh071atPlhszFDj2_bI/edit

@export var screenNotifier: VisibleOnScreenNotifier2D
# Nodos que queremos ocultar
@export var nodes: Array[Node2D] = []
# Una referencia del padre de cada nodo (para poder hacer add_child y remove_child)
var parents: Array[Node2D] = []
# Para no agregar o eliminar dos veces, manejamos una variable para indicar el estado de los nodos
# Agregado/No Agregaod: por defecto, los nodos están agregados al árbol de nodos (en la escena)
var nodes_added = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Si no tenemos un notificador, terminamos la función
	if !screenNotifier:
		return
		
	# Si no tenemos nodos a procesar, terminamos la función
	if nodes.size() == 0:
		return
		
	# Importante guardar todos los nodos padre, para poder agregar o remover hijos
	for node in nodes:
		var parent = node.get_parent()
		parents.append(parent)

	# Asociamos eventos, para "escuchar" cuando la camara entra o sale del área del notificador
	screenNotifier.screen_entered.connect(_screen_entered)
	screenNotifier.screen_exited.connect(_screen_exited)

# Se efecuta cuando se entra al área del notificador
# Se deben agregar todos los nodos al árbol principal de la escena
func _screen_entered():
	# Si los nodos ya están agregados, solo terminamos la función
	if nodes_added:
		return
	# Eliminamos (del árbol de nodos) los objetos que no queremos que se procesen
	for node in nodes:
		var parent = _get_parent(node)
		parent.add_child(node)
	nodes_added = true # Indicamos que agregamos nodos

# Se efecuta cuando se sale del área del notificador
# Se deben eliminar todos los nodos del árbol principal de la escena
func _screen_exited():
	# Si los nodos ya están eliminados, solo terminamos la función
	if !nodes_added:
		return
	# Eliminamos (del árbol de nodos) los objetos que no queremos que se procesen
	for node in nodes:
		var parent = node.get_parent()
		parent.remove_child(node)
	nodes_added = false # Indicamos que eliminamos nodos

# Sirve para buscar el padre de un nodo
func _get_parent(node: Node2D):
	var index = nodes.find(node)
	return parents[index]
