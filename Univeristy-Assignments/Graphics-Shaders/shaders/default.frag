uniform vec3 color;
varying vec3 world_normal;

void main() {
  gl_FragColor = vec4(color, 1.0);
}
