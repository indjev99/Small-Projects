uniform vec3 light_dir;
uniform float ambient_light;
uniform vec3 camera_position;
uniform vec3 color;
uniform float diffusion;
uniform float reflection;
varying vec3 world_normal;
varying vec3 world_position;

void main() {
  vec3 world_normal_n = normalize(world_normal);
  vec3 light_dir_n = normalize(light_dir);
  vec3 out_light_dir = reflect(light_dir_n, world_normal_n);
  vec3 view_dir = normalize(world_position - camera_position);

  float light_diff = dot(light_dir_n, world_normal_n);
  float light_refl = dot(out_light_dir, view_dir);

  if (light_diff < 0.0) {
      light_refl = 0.0;
  }

  light_diff = max(light_diff, 0.0);
  light_refl = max(light_refl, 0.0);

  float light = min(ambient_light + light_diff * diffusion, 1.0);
  light = min(light + light_refl * reflection, 1.0 + reflection);

  gl_FragColor = vec4(light * color, 1.0);
}
