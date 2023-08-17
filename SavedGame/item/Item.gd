extends TextureButton

#Declaramos el estado del elemento del grid
var selected = false
#Declaramos el estado de la celda
var empty = false
#Id de la escena
var id = ''
#Ruta de la escena
var path = ''

#Declaramos la ruta del estado a cargar
@export var scenePath : String
#Declaramos el nodo del padre
@export var parent : Node2D

#Declaramos el nodo del padre
@export var colorRect : ColorRect
#Se permiten todas acciones
var onlyLoad = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var scenes = ["Map"]
	var actual_scene = get_tree().get_current_scene().name
	if (scenes.find(actual_scene,0) > -1):
		onlyLoad = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	#Validamos si no esta sseleccionado el elemento
	if !selected:
		#Ajustamos la transparencia
		modulate.a8=200

func _on_mouse_exited():
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
	Global.activeItemMenuId = id
	Global.itemMenuPath = path
	parent.actions.visible = true
	if onlyLoad: 
		if !empty:
			parent.loadButton.visible = true
		else:
			parent.loadButton.visible = false
	elif empty:
		parent.saveButton.visible = true
		parent.removeButton.visible = false
		parent.loadButton.visible = false
	else:
		parent.saveButton.visible = true
		parent.removeButton.visible = true
		parent.loadButton.visible = true
	
func reset():
	#Seteamos el estado como no seleccionado
	selected = false
	#Ajustamos la transparencia
	modulate.a8=255
