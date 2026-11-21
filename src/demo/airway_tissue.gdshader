shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, specular_schlick_ggx;

// Procedural mucosa: warm tissue with mottling and a soft rim, so the airway
// reads as flesh rather than a painted pipe. Demo-only; the engine keeps a
// plain material so the simulator stays cheap.
uniform vec3 base_colour : source_color = vec3(0.58, 0.26, 0.24);
uniform vec3 deep_colour : source_color = vec3(0.19, 0.06, 0.07);
uniform float mottle_scale = 900.0;

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float n = hash(floor(world_pos * mottle_scale));
	float n2 = hash(floor(world_pos * mottle_scale * 0.31));
	vec3 colour = mix(deep_colour, base_colour, 0.55 + 0.30 * n + 0.15 * n2);

	ALBEDO = colour;
	ROUGHNESS = 0.82;
	SPECULAR = 0.22;

	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = vec3(0.30, 0.10, 0.09) * rim * 0.55;
}
