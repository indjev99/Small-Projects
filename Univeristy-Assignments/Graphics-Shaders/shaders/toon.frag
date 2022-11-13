uniform vec3 light_dir;
uniform float ambient_light;
uniform vec3 color;
uniform float color_res;
varying vec3 world_normal;

void main() {
  vec3 world_normal_n = normalize(world_normal);
  vec3 light_dir_n = normalize(light_dir);
  float light = dot(world_normal_n, light_dir_n);
  light = min(max(light, 0.0) + ambient_light, 1.0);
  gl_FragColor = vec4(light * color, 1.0);
  gl_FragColor[0] = round(gl_FragColor[0] * color_res) / color_res;
  gl_FragColor[1] = round(gl_FragColor[1] * color_res) / color_res;
  gl_FragColor[2] = round(gl_FragColor[2] * color_res) / color_res;
}
