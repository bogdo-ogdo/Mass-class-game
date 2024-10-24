shader_type canvas_item;

uniform float offset = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform float distortion_strength : hint_range(-1,1) = 0.2;
uniform float distortion_speed;

void fragment() {
	vec4 noise_col = texture(noise, UV + scroll + TIME * distortion_speed);
	
	
	vec4 green_channel = texture(screen_texture, SCREEN_UV + distortion_strength * noise_col.rr);
	vec4 red_channel = texture(screen_texture, vec2(SCREEN_UV.x + (offset * SCREEN_PIXEL_SIZE.x) + distortion_strength * noise_col.rr.x, SCREEN_UV.y + distortion_strength * noise_col.rr.y));
	vec4 blue_channel = texture(screen_texture, vec2(SCREEN_UV.x - (offset * SCREEN_PIXEL_SIZE.x) + distortion_strength * noise_col.rr.x, SCREEN_UV.y +  distortion_strength * noise_col.rr.y));
	COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
