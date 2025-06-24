@vs vs
in vec3 position;

out vec4 pos;


void main() {
    	gl_Position = vec4(position.x/1.0, position.y/1.0, position.z, 1.0);
	pos.x = position.x*16;
	pos.y = position.y*9;
}
@end

@fs fs
/*
uniform fs_params {
	vec4 ci[5];
};
*/

struct Ray {
	vec3 orig;
	vec3 dir;
};

in vec4 pos;

out vec4 frag_color;

vec3 at(in Ray r, in float t) {
	return r.orig + t * r.dir;
}

void main() {
	Ray r = Ray(vec3(1.0), vec3(0.5));
	frag_color = vec4(abs(pos.x), abs(pos.y), 0.0, 1.0);
}
@end

@program rtc vs fs
