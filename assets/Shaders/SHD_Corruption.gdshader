shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.08);
uniform vec3 void_color : source_color = vec3(0.1, 0.0, 0.15);
uniform float flow_speed : hint_range(0.1, 5.0) = 1.0;
uniform float corruption_intensity : hint_range(0.0, 1.0) = 0.5;

instance uniform float flash_weight = 0.0;
instance uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

// Basic hash for noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
    float t = TIME * flow_speed;
    vec2 noise_uv = UV * 5.0 + vec2(t, t * 0.5);
    float n = noise(noise_uv);
    
    vec3 final_color = mix(base_color, void_color, n * corruption_intensity);
    
    // Hit flash logic
    ALBEDO = mix(final_color, flash_color, flash_weight);
    EMISSION = void_color * n * corruption_intensity * 2.0;
    ROUGHNESS = 0.9;
}
