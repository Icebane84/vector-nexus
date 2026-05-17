shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// The texture map slot for the Inspector
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;

instance uniform float flash_weight = 0.0;
instance uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
    // Read the pixel color from your texture map
    vec4 tex_color = texture(albedo_texture, UV);
    
    // Mix the texture color with pure white based on hit weight
    ALBEDO = mix(tex_color.rgb, flash_color, flash_weight);
    
    // Preserve the original alpha if your texture has transparency
    ALPHA = tex_color.a; 
}
