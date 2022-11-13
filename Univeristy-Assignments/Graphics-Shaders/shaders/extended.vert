varying vec3 world_normal;
varying vec3 world_position;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

  world_normal = normalize(mat3(modelMatrix) * normal);
  world_position = (modelMatrix * vec4(position, 1.0)).xyz;
}
