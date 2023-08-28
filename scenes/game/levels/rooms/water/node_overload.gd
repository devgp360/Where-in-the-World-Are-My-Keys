extends Node2D
## Clase que maneja el efecto de agua
## 
## Precarga la imagen de agua sin efectos, genera múltiples llamadas que generan el efecto de agua

@export var active_process = true; # Indica si el proceso está activo

var count = 0; # Variable auxiliar para conteo de carga de imágenes


# Se ejecuta en cada frame
func _process(delta):
	# Si no está activo, terminamos la función
	if !active_process:
		return
	intensive_loop()
	intensive_call_test()
	#multi_load()


# Genera un ciclo que ejecuta 1 millón de multiplicaciones
func intensive_loop():
	# Realizar una operación intensiva (simulando carga en la CPU)
	var result = 0
	for i in range(1000000):
		result += i * i


# Función que se ejecutará 100 veces
func intensive_call():
	print("call")


# Función que ejecuta otra función (100 veces)
func intensive_call_test():
	for i in range(100):
		intensive_call()


# Función que carga una imagen y la añade al árbol de nodos
func multi_load():
	var image = load("res://Scenes/Water/Assets/iglesia_sin_agua_bg.png")
	var sprite = Sprite2D.new()
	sprite.texture = image
	var w = get_tree().get_root().get_node("Water")
	w.add_child(sprite)
	count = count + 1
	print("Imagen: ", count)
