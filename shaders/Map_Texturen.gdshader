shader_type spatial;

uniform sampler2D textur_basis : source_color;
uniform sampler2D textur_rot : source_color;
uniform sampler2D textur_gruen : source_color;
uniform float kachelung = 10.0;

void fragment() {
    vec2 kachel_uv = UV * kachelung;
    
    vec3 basis = texture(textur_basis, kachel_uv).rgb;
    vec3 rot = texture(textur_rot, kachel_uv).rgb;
    vec3 gruen = texture(textur_gruen, kachel_uv).rgb;
    
    vec3 ergebnis = mix(basis, rot, COLOR.r);
    ergebnis = mix(ergebnis, gruen, COLOR.g);
    
    ALBEDO = ergebnis;
}
