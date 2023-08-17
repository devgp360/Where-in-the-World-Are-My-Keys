extends Node2D

# Variables de nodos principales
@onready var canvas = $CanvasLayer
@onready var planta1 = $CanvasLayer/Plantas/Planta1
@onready var planta2 = $CanvasLayer/Plantas/Planta2
@onready var planta3 = $CanvasLayer/Plantas/Planta3
@onready var planta4 = $CanvasLayer/Plantas/Planta4
@onready var planta5 = $CanvasLayer/Plantas/Planta5
@onready var planta6 = $CanvasLayer/Plantas/Planta6
@onready var cup = $CanvasLayer/cup
@onready var label = $CanvasLayer/ColorRect/Label
@onready var animation = $CanvasLayer/AnimationPlayer
@onready var disolve = $CanvasLayer/Disolve
@onready var center = $CanvasLayer/Disolve/Centro
@onready var btn_cerrar = $CanvasLayer/Cerrar
# Textos a mostrar en el puzzle
@export var TextoAgregado = "¡Planta agregada!"
@export var TextoYaAgregado = "La planta ya está agregada."
@export var TextoMaximoAgregado = "Ya tenemos 3 plantas. No se pueden agregar más."
@export var TextoAgregadoInvalido = "Esa planta no se puede cortar del jardín."
@export var TextoAgregadoInventario = "Bebida agregada al inventario."

var plant_active = "" # Planta activa (resaltada)
var cup_position = Vector2(0, 0) # Para guardar la posición (inicial) del vaso

# Función de inicialización
func _ready():
	cup.add_on_blend(on_blend)
	cup.add_on_hide_potion(on_hide_potion)
	cup.add_on_add_inventory(on_add_inventory)
	cup_position = cup.position
	disolve.visible = false
	btn_cerrar.pressed.connect(close)
	canvas.visible = false

# Lee eventos del teclado y ratón
func _unhandled_input(event):
	if event.is_action_pressed("click") and plant_active:
		# Funcionalidad de agregar planta al "vaso"
		if plant_active == "#":
			label.text = TextoAgregadoInvalido
		elif cup.exists_plant(plant_active):
			label.text = TextoYaAgregado
		else:
			# Mostrar mensaje de "agregado" (o no) de la planta
			var added = cup.add_plant(plant_active)
			if added:
				label.text = TextoAgregado
			else:
				label.text = TextoMaximoAgregado

# Al dar clic en botón "mezclar"
func on_blend():
	disolve.visible = true
	animation.play("disolve")
	await animation.animation_finished
	cup.show_potion(center.position)

# Función para ocultar el vaso
func on_hide_potion():
	animation.play_backwards("disolve")
	await animation.animation_finished
	disolve.visible = false

# Añadir el "brebaje" resultante de la mezcla, hacia el inventario
func on_add_inventory():
	label.text = TextoAgregadoInventario

# Cerrar el puzzle
func close():
	canvas.visible = false

# Mostrar el puzzle
func _set_visible(visible: bool):
	canvas.visible = visible

# Funciones para detectar cuando el puntero entra o sale de una planta
func _on_area_planta_1_mouse_entered():
	planta1.visible = true
	plant_active = "ruda"

func _on_area_planta_1_mouse_exited():
	planta1.visible = false
	plant_active = ""

func _on_area_planta_2_mouse_entered():
	planta2.visible = true
	plant_active = "romero"

func _on_area_planta_2_mouse_exited():
	planta2.visible = false
	plant_active = ""

func _on_area_planta_3_mouse_entered():
	planta3.visible = true
	plant_active = "aloe_vera"

func _on_area_planta_3_mouse_exited():
	planta3.visible = false
	plant_active = ""

func _on_area_planta_4_mouse_entered():
	planta4.visible = true
	plant_active = "chaya"

func _on_area_planta_4_mouse_exited():
	planta4.visible = false
	plant_active = ""

func _on_area_planta_5_mouse_entered():
	planta5.visible = true
	plant_active = "#"

func _on_area_planta_5_mouse_exited():
	planta5.visible = false
	plant_active = ""

func _on_area_planta_6_mouse_entered():
	planta6.visible = true
	plant_active = "equinacea"

func _on_area_planta_6_mouse_exited():
	planta6.visible = false
	plant_active = ""
