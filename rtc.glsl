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
	vec2 mouse;
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

float hit_sphere(in vec3 center, in float radius, in Ray r) {
	vec3 oc = center - r.orig;
	float a = dot(r.dir, r.dir);
	float b = -2.0 * dot(r.dir, oc);
	float c = dot(oc, oc) - radius*radius;
	float discriminant = b*b - 4*a*c;

	if (discriminant < 0) {
		return -1.0;
	} else {
		return (-b - sqrt(discriminant)) / (2.0*a);
	}
}

vec3 ray_color(in Ray r) {
	vec3 sphere_loc = vec3(0, 0, -1);
	float t = hit_sphere(sphere_loc, 0.5, r);
	if (t >= 0.0) {
		vec3 n = normalize(at(r, t) - sphere_loc);
		return (n + 1.0)*0.5;
	}
	vec3 unit_direction = normalize(r.dir);
	float a = 0.5*(unit_direction.y + 1.0);
	return (1.0-a)*vec3(1.0, 1.0, 1.0) + a*vec3(mouse, 1.0);
}

void main() {
	// gl_FragCoord

	// for all the pixels:
	float focal_length = 1.0;
	vec3 cam_center = vec3(0.0, 0.0, 0.0);

	float aspect_ratio = res.x/res.y;
	vec3 viewport = vec3(2.0*aspect_ratio, 2.0, 0);

	vec3 pixel_delta = vec3(viewport.x/res.x, viewport.y/res.y, 0.0); // the viewport is from -1 to 1
	vec3 viewport_lower_left = cam_center - vec3(0.0, 0.0, focal_length) - vec3(viewport.x / 2.0, viewport.y / 2.0, 0.0);
	vec3 pixel00_loc = viewport_lower_left + 0.5 * pixel_delta;

	// for this pixel:
	vec3 pixel_center = pixel00_loc + vec3(gl_FragCoord.x * pixel_delta.x, gl_FragCoord.y * pixel_delta.y, 0.0);
	vec3 ray_direction = pixel_center - cam_center;
	Ray r = Ray(cam_center, ray_direction);

	vec3 pixel_color = ray_color(r);
	
	frag_color = vec4(pixel_color, 1.0);
}
@end

@program rtc vs fs
