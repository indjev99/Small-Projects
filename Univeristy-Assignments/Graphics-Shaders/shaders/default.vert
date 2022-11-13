varying vec3 world_normal;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

  world_normal = normalize(mat3(modelMatrix) * normal);
}
