uniform vec3 light_dir;
uniform float ambient_light;
uniform vec3 color;
varying vec3 world_normal;

void main() {
  vec3 world_normal_n = normalize(world_normal);
  vec3 light_dir_n = normalize(light_dir);
  float light = dot(world_normal_n, light_dir_n);
  light = min(max(light, 0.0) + ambient_light, 1.0);
  gl_FragColor = vec4(light * color, 1.0);
}
