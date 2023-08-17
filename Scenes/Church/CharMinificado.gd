extends CharacterBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation = $AnimationPlayer
@export var light_node: Node2D

# Constantes de sombra
# BOTTON: Personaje "debajo" del punto de luz
# TOP: Personaje "arriba" del punto de luz
var SHADER_OFFSET_Y_BOTTOM = 2.0 # Posición de sombra en Y (en BOTTOM)
var SHADER_OFFSET_Y_TOP = 42.0 # Posición de sombra en Y (en TOP)
var SHADER_DEFORM_Y = 1.0 # La sombra es la mitad del tamaño de personaje (en el punto 0 en X)
var SHADER_OFFEXT_X_FACTOR_BOTTOM = 250.0 # Posición de sombra en X (en BOTTOM)
var SHADER_OFFSET_X_FACTOR_TOP = 150.0 # Posición de sombra en X (en TOP)

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("walk")
	dynamic_shader()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_direction(delta)
	

func update_direction(delta):
	var dir_x = Input.get_axis("ui_left", "ui_right")
	var dir_y = Input.get_axis("ui_down", "ui_up")
	
	velocity.y = 0
	velocity.x = 0
	var speed = 200
	
	if dir_y < 0:
		velocity.y = 1 * speed;
	elif dir_y > 0:
		velocity.y = -1 * speed;
	if dir_x < 0:
		velocity.x = -1 * speed;
	elif dir_x > 0:
		velocity.x = 1 * speed;
	if dir_x != 0 or dir_y != 0:
		move_and_slide()
		dynamic_shader()


func dynamic_shader():
	# Si no está seteado un punto de luz, solo retornamos sin sombra
	if !light_node:
		sprite.material.set("shader_param/opacity", 0.0)
		return

	# Dirección de movimiento (desde -180 grados a 180 grados (los 360 grados del círculo)
	var move_direction = rad_to_deg(light_node.position.angle_to_point(position))
	# Si es verdadero, indica que el personaje está por encima del punto de luz
	var character_is_over_light = false
	# Hacemo el vector más pequeño, para que esté en el rango de "unidades"
	move_direction = move_direction * 0.01
	# Si estemos sobre el punto de luz
	if move_direction < 0:
		move_direction = move_direction * -1 # Hacemos negativa la dirección
		character_is_over_light = true # Guardamos que estasmos sobre la luz

	# Calculamos la "deformación" de la sombra
	# Se estira hacia el lado derecho o izquierdo
	var deformY = SHADER_DEFORM_Y
	var deformX = move_direction - 1
	if character_is_over_light:
		deformX = deformX * -1 # Si estamos sobre la luz, hacemos la deformación negativa

	# Calculamos la posición de la sombra, respecto al sprite del personaje
	# La sombra inicia siempre en los "pies" del personaje
	var offsetY = SHADER_OFFSET_Y_BOTTOM;
	var offsetX = deformX * SHADER_OFFEXT_X_FACTOR_BOTTOM;
	if character_is_over_light:
		offsetY = SHADER_OFFSET_Y_TOP
		offsetX = deformX * SHADER_OFFSET_X_FACTOR_TOP;

	# Generamos las variables para pasar al "shader"
	var deform = Vector2(deformX, deformY);
	var offset = Vector2(offsetX, offsetY);

	# Calculamos una opacidad de la sombra, en base a la distancia del personaje a un punto de luz
	var distance = light_node.position.distance_to(self.position);
	var d = distance / 1000;
	var opacity = 1 - lerp(0.1, 0.9, d);

	# Pasamos parámetros al "shader"
	sprite.material.set("shader_param/deform", deform)
	sprite.material.set("shader_param/opacity", opacity)
	sprite.material.set("shader_param/offset", offset)
	sprite.material.set("shader_param/flipY", !character_is_over_light)
