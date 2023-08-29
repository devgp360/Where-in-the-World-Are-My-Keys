extends Node
## Clase que guarda las variables globales
##
## Se definen las variables globales que van a ser accesibles en todo el juego


# DOCUMENTACIÓN ¿QUÉ SON LAS ESCENAS/VARIABLES GLOBALES?: https://docs.google.com/document/d/1bs4webBtE0duQdl5RqrBRakfwm1_IIzrXN_UOrItuLA

#Nivel del sonido de la musica del juego
var music_vol = 1

#Nivel del sonido del personaje principal del juego
var main_character_vol = 1

#Nivel del sonido del npc del juego
var npc_vol = 1

#Id del guardado del juego (celda seleccionada)
var active_item_menu_id = ""

#Estado del item guardado del juego (si la celda seleccionada es vacia o llena)
var item_menu_empty = true

#Ruta de la escena seleccionada del guardado del juego
var item_menu_path = ""
