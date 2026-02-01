shader_type spatial;
render_mode unshaded, fog_disabled;


uniform sampler2D screen_texture : hint_screen_texture;
uniform float pixel_size : hint_range(0.0, 20.0, 1.0);
uniform float levels : hint_range(0.0,100.0,1.0);
uniform vec2 gamma;

render_mode cull_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	vec2 pixel_count = tex_size / pixel_size;
	vec2 pixelated_uv = floor(SCREEN_UV * pixel_count) / pixel_count;
	vec4 color = texture(screen_texture, pixelated_uv);
	
	color.rgb = pow(color.rgb, vec3(gamma.x));
	
	float greyscale = max(color.r, max(color.g, color.b));
	float lower = floor(greyscale * levels) / levels;
	float higher = ceil(greyscale * levels) / levels;

	float lower_diff = abs(lower - greyscale);
	float higher_diff = abs(higher - greyscale);
	
	float level = lower * float(lower_diff < higher_diff) + higher * float(lower_diff > higher_diff);
	float adjustment = level / greyscale;
	
	color.rgb *= adjustment;
		color.rgb = pow(color.rgb, vec3(gamma.y));
	
	ALBEDO = color.rgb;
	//ALPHA = color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
