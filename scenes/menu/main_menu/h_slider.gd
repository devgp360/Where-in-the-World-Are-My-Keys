extends HSlider
## Clase que controla el nodo HSlider
##
## Lee el nivel de sonido de cada canal de audios, escucha el cambio de valor del slider, guarda nuevo valor de nivel de sonido


#Exportamos el nombre tipo de sonido
@export var bus_name: String

var bus_index: int


# Función que se llama cuando la escena esta cargada
func _ready():
	#Obtenemos el index del canal del sonido
	bus_index = AudioServer.get_bus_index(bus_name)
	#Seteamos el nivel del sonido
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(Global[bus_name + "_vol"]))
	#Seteamos el value del slider del medidor de sonido
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	#Conectamos el evento change del slider
	value_changed.connect(_on_value_changed)


# Función que se llama cuando se hace el cambio del valor de volumen del sonido
func _on_value_changed(_value:float) -> void:
	#Seteamos el nivel del sonido
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(_value))
	#guardamos el nivel del sonido
	SaveProgress.save_sounds(bus_name, _value)
	#Seteamos la variable global del sonido
	Global[bus_name + "_vol"] = _value
