extends Node2D

@onready var aceite = $Aceite

# Función de inicialización
func _ready():
	aceite.visible = false

# Función para mostrar "aceite" en la piedra
func _agregar_aceite():
	aceite.visible = true

# Cuando el puntero entra en la piedra
func _on_piedra_grande_mouse_entered():
	var current = InventoryCanvas.get_current_item_name_selected()
