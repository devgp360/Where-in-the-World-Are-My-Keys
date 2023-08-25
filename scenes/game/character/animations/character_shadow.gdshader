/**
* Shadow 2D.
* License: CC0
* https://creativecommons.org/publicdomain/zero/1.0/
* DOCUMENTACIÓN (sombras): https://docs.google.com/document/d/1IAQRxm-IrOKRFd6XK9IlnbYYaLb_Bt0VDyqVeKR42j0/edit?usp=drive_link
*/
shader_type canvas_item;
render_mode blend_mix;
uniform vec2 deform = vec2(2.0, 2.0); // Deformación de la sombra
uniform vec2 offset = vec2(0.0, 0.0); // Posición de la sombra
uniform vec4 modulate = vec4(0.0, 0.0, 0.0, 0.0); // Color de la sombra (r, g, b, a)
uniform bool flipY = false; // Invertir sombra en eje Y
uniform float opacity = 0.5; // Opacidad de la sombra (0.0 - 1.0)

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV;
	float sizex = float(textureSize(TEXTURE,int(ps.x)).x);
	float sizey = float(textureSize(TEXTURE,int(ps.y)).y);
	
	// Coordenadas de textura originales
    vec2 texcoord = FRAGCOORD.xy / vec2(1000.0, 600.0);
	vec4 _modulate = modulate;
	_modulate.a = opacity; // aplicando transparencia
	// Generando la sombra del personaje, en base al contorno del "sprite"
	uv.y+=offset.y*ps.y;
	uv.x+=offset.x*ps.x;
	float decalx=((uv.y-ps.x*sizex)*deform.x);
	float decaly=((uv.y-ps.y*sizey)*deform.y);
	uv.x += decalx;
	uv.y += decaly;
	// Si está activado "flipY" (voltear verticalmente), se pondrá la sombra "de cabeza"
	if (flipY) {
		uv.y = 1.0 - uv.y;
	}
	// Seteamos la sombra y el color para render
	vec4 shadow = vec4(_modulate.rgb, texture(TEXTURE, uv).a * _modulate.a);
	vec4 col = texture(TEXTURE, UV);
	COLOR = mix(shadow, col, col.a);
}