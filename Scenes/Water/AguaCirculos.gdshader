// DOCUMENTACIÓN (catálogo de objetos): https://docs.google.com/document/d/18iHv1BZWBa-CwEjg-H-nAnRvlIHsx-qWlEdDVcI0-uM/edit
shader_type canvas_item;

// Declaración del tipo de shader
// Indica que este es un shader para un objeto de tipo "canvas_item"

// para círculos
uniform float amplitud: hint_range(0, 2, 0.01) = 2.0;
uniform float frecuencia: hint_range(0, 15, 0.01) = 12.69;
uniform float tasaRizado : hint_range(0.5, 150.0, 0.1) = 9.2;

// Variables para controlar los círculos
// Estas variables te permiten ajustar la apariencia de los círculos en la superficie del agua

// para ondas
uniform float amplitudOndas = 0.1;
uniform float frecuenciaOndas = 4.0;
uniform float cantidadMezcla = 0.6;

// Variables para controlar el movimiento de las ondas y la mezcla
// Estas variables controlan el efecto de las ondas y cómo se mezclan con el agua

// otros
uniform sampler2D ruido;

// Una textura utilizada para agregar algo de aleatoriedad a la apariencia del agua
// Esta textura puede introducir variaciones en el efecto del agua

vec2 onda(vec2 uv, float tiempo) {
    return vec2(
        uv.x + sin(uv.y * frecuenciaOndas * 5.0 + tiempo) * amplitudOndas,
        uv.y + sin(uv.x * frecuenciaOndas + tiempo) * amplitudOndas
    );
}

// Función para simular el movimiento de las ondas
// Esta función calcula el desplazamiento de las coordenadas UV basado en una onda senoidal, creando un efecto similar al de las ondas

void fragment() {
    vec2 uvOndas = onda(UV, TIME);
    vec4 ns = texture(ruido, uvOndas);

    // Muestrea la textura de ruido en la coordenada UV desplazada por las ondas
    // Esto introduce ruido a la superficie del agua, agregando aleatoriedad al efecto

    vec2 movimiento = vec2(0.0, 1.0);
    float pi = 3.14159265358979323846;
    vec2 uv = UV * 2.0 - 1.0;

    // Calcula la distancia desde el centro del espacio UV
    // Esto se utiliza para crear círculos de ondulación

    float distancia = length(uv);
    ns *= 1.4142135;
    distancia += -0.1 * ns.x;

    // Calcula el efecto de ondulación usando la función seno
    // Esto crea la apariencia ondulante en la superficie del agua

    float ondulacion = sin(distancia * -frecuencia * pi + tasaRizado * TIME) * amplitud / (distancia + 1.0);

    // Establece el color base del agua
    vec4 color = vec4(0.6, 0.6, 0.6, 1.0 * ondulacion);

    // Calcula la escala alfa basada en la distancia y el ruido
    float escalaAlfa = (1.0 - min(distancia, 1.0)) * ns.x * 2.5;

    // Modifica el canal alfa del color
    color.a *= 1.0 * escalaAlfa * (ondulacion + ns.x * ns.y);
    color.a = max(color.a - (ns.y * 0.45), 0.0);

    // Asigna el color final a la salida
    COLOR = color;
}

// La función fragment es el núcleo del shader y calcula el color de cada fragmento (píxel) en el objeto canvas_item.
// Combina varios efectos, simulaciones de ondas y ruido para lograr la apariencia de agua con ondulaciones y reflejos.