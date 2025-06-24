@vs vs
in vec3 position;

out vec4 pos;


void main() {
    	gl_Position = vec4(position.x/1.0, position.y/1.0, position.z, 1.0);
	pos.x = position.x;
	pos.y = position.y;
}
@end

@fs fs

uniform fs_params {
	vec2 res;
};


struct Ray {
	vec3 orig;
	vec3 dir;
};

in vec4 pos;

out vec4 frag_color;

vec3 at(in Ray r, in float t) {
	return r.orig + t * r.dir;
}

vec3 ray_color(in Ray r) {
	return vec3(0);
}

void main() {
	// gl_FragCoord

	// for all the pixels:
	float focal_length = 1.0;
	vec3 cam_center = vec3(0, 0, 0);

	vec3 viewport = vec3(2.0, 2.0, 0);

	vec3 pixel_delta = vec3(2.0/res.x, 2.0/res.y, 0.0); // from -1 to 1
	vec3 viewport_lower_left = cam_center - vec3(0.0, 0.0, focal_length) - viewport.x / 2.0 - viewport.y / 2.0;
	vec3 pixel00_loc = viewport_lower_left + 0.5 * pixel_delta;

	// for this pixel:
	vec3 pixel_center = pixel00_loc + (gl_FragCoord.x * pixel_delta.x) + (gl_FragCoord.y * pixel_delta.y);
	vec3 ray_direction = pixel_center - cam_center;
	Ray r = Ray(cam_center, ray_direction);

	vec3 pixel_color = ray_color(r);
	
	frag_color = vec4(pixel_color, 1.0);
}
@end

@program rtc vs fs
