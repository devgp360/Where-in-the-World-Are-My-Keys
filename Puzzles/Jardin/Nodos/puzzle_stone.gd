extends Node2D
# DOCUMENTACIÓN SOBRE COLISIONADORES Y "COLLISIONSHAPES": https://docs.google.com/document/d/1FFAJSrAdE5xyY_iqUteeajHKY3tAIX5Q4TokM2KA3fw

@onready var aceite = $Aceite

# Función de inicialización
func _ready():
	aceite.visible = false

# Función para mostrar "aceite" en la piedra
func _agregar_aceite():
	aceite.visible = true

# Cuando el puntero entra en la piedra
func _on_piedra_grande_mouse_entered():
	pass
	#var current = InventoryCanvas.get_current_item_name_selected()
