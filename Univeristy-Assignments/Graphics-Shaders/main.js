
resources = {
  vert_shader :
    `
    varying vec3 world_normal;
    varying vec3 world_position;

    void main() {
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

      world_normal = normalize(mat3(modelMatrix) * normal);
      world_position = (modelMatrix * vec4(position, 1.0)).xyz;
    }
    `
  ,
  flat_frag_shader :
    `
    uniform vec3 color;
    varying vec3 world_normal;

    void main() {
      gl_FragColor = vec4(color, 1.0);
    }
    `
  ,
  lighting_frag_shader :
    `
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
    `
  ,
  toon_frag_shader :
    `
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
    `
  ,
  reflective_frag_shader :
    `
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
    `
  ,
  reflective_toon_frag_shader :
    `
    uniform vec3 light_dir;
    uniform float ambient_light;
    uniform vec3 camera_position;
    uniform vec3 color;
    uniform float diffusion;
    uniform float reflection;
    uniform float color_res;
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

      gl_FragColor[0] = round(gl_FragColor[0] * color_res) / color_res;
      gl_FragColor[1] = round(gl_FragColor[1] * color_res) / color_res;
      gl_FragColor[2] = round(gl_FragColor[2] * color_res) / color_res;
    }
    `
}


/* Create the scene */

function initialise_scene() {
  // You can use your loaded resources here; resources.vert_shader will
  // be the content of the vert_shader file listed in RESOURCES, for
  // example

  // Set up the key parts of your renderer: a camera, a scene and the renderer
  var scene = new THREE.Scene();
  scene.fog = new THREE.FogExp2(0x7c7c7c, 0.002);
  
  var camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
  camera.position.z = 30;

  var renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setClearColor(scene.fog.color, 1);
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.appendChild(renderer.domElement);

  function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  };

  window.addEventListener('resize', onWindowResize, false)

  // Controls
  controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.update();

  // Materials

  function flatMaterial(r, g, b) {
    return new THREE.ShaderMaterial({
      uniforms: {
        color: {value: new THREE.Vector3(r, g, b)}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["flat_frag_shader"]
    });
  };

  function lightingMaterial(r, g, b) {
    return new THREE.ShaderMaterial({
      uniforms: {
        light_dir: {value: new THREE.Vector3(1, 1, 1)},
        ambient_light: {value: 0.2},
        color: {value: new THREE.Vector3(r, g, b)}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["lighting_frag_shader"]
    });
  };

  function toonMaterial(r, g, b, res) {
    return new THREE.ShaderMaterial({
      uniforms: {
        light_dir: {value: new THREE.Vector3(1, 1, 1)},
        ambient_light: {value: 0.2},
        color: {value: new THREE.Vector3(r, g, b)},
        color_res: {value: res}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["toon_frag_shader"]
    });
  };

  function reflectiveMaterial(r, g, b, diff, refl) {
    return new THREE.ShaderMaterial({
      uniforms: {
        light_dir: {value: new THREE.Vector3(1, 1, 1)},
        ambient_light: {value: 0.2},
        camera_position: {value: camera.position},
        color: {value: new THREE.Vector3(r, g, b)},
        diffusion: {value: diff},
        reflection: {value: refl}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["reflective_frag_shader"]
    });
  };

  function reflectiveToonMaterial(r, g, b, diff, refl, res) {
    return new THREE.ShaderMaterial({
      uniforms: {
        light_dir: {value: new THREE.Vector3(1, 1, 1)},
        ambient_light: {value: 0.2},
        camera_position: {value: camera.position},
        color: {value: new THREE.Vector3(r, g, b)},
        diffusion: {value: diff},
        reflection: {value: refl},
        color_res: {value: res}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["reflective_toon_frag_shader"]
    });
  };

  // Objects

  geometry = new THREE.BoxGeometry(4, 4, 4);
  material = new THREE.MeshLambertMaterial({ color: 0xffffff });
  cube = new THREE.Mesh(geometry, material);
  cube.position.set(-10, 5, -5);
  scene.add(cube);

  geometry = new THREE.ConeGeometry(6, 12, 32);
  material = reflectiveMaterial(1.0, 0.8, 0.0, 0.6, 0.6);
  cone = new THREE.Mesh(geometry, material);
  cone.position.set(20, 0, -25);
  scene.add(cone);

  geometry = new THREE.SphereGeometry(6, 1024, 1024);
  material = new THREE.MeshPhongMaterial({ color: 0xff7f7f });
  sphere = new THREE.Mesh(geometry, material);
  sphere.position.set(-35, -15, -35);
  scene.add(sphere);

  geometry = new THREE.SphereGeometry(3, 1024, 1024);
  material = reflectiveMaterial(0.3, 0.6, 0.4, 0.3, 1.0);
  r_sphere = new THREE.Mesh(geometry, material);
  r_sphere.position.set(1, -13, 0);
  scene.add(r_sphere);

  geometry = new THREE.TorusGeometry(8, 0.75, 1024, 1024);
  material = reflectiveToonMaterial(1.0, 0.0, 0.0, 0.7, 0.3, 2.0);
  ring1 = new THREE.Mesh(geometry, material);
  ring1.position.set(15, -15, -10);
  scene.add(ring1);

  geometry = new THREE.TorusGeometry(5, 0.75, 1024, 1024);
  material = reflectiveToonMaterial(0.0, 1.0, 0.0, 0.7, 0.3, 3.0);
  ring2 = new THREE.Mesh(geometry, material);
  ring2.position.set(15, -15, -10);
  scene.add(ring2);

  geometry = new THREE.TorusGeometry(2, 0.75, 1024, 1024);
  material = reflectiveToonMaterial(0.0, 0.0, 1.0, 0.7, 0.3, 4.0);
  ring3 = new THREE.Mesh(geometry, material);
  ring3.position.set(15, -15, -10);
  scene.add(ring3);

  geometry = new THREE.TorusKnotGeometry(3, 0.5, 1024, 1024);
  material = new THREE.MeshPhysicalMaterial({ color: 0xaf00ff });
  material.clearcoat = 1.0;
  torusKnot = new THREE.Mesh(geometry, material);
  torusKnot.position.set(0, 10, 0);
  scene.add(torusKnot);

  geometry = new THREE.TorusKnotGeometry(4, 0.65, 1024, 1024);
  material = reflectiveToonMaterial(0.55, 0.25, 1.0, 0.4, 0.6, 3.0);
  material.clearcoat = 1.0;
  torusKnot2 = new THREE.Mesh(geometry, material);
  torusKnot2.position.set(-10, -8, -5);
  scene.add(torusKnot2);

  geometry = new THREE.BoxGeometry(3.5, 2, 5);
  material = reflectiveMaterial(0.1, 0.9, 0.8, 0.9, 0.1);
  box = new THREE.Mesh(geometry, material);
  box.position.set(-1.5, -3, 5);
  scene.add(box);

  // Lights
  light = new THREE.DirectionalLight(0xffffff);
  light.position.set(1, 1, 1);
  scene.add(light);

  light = new THREE.DirectionalLight(0x002288);
  light.position.set(-1, -1, -1);
  scene.add(light);

  light = new THREE.AmbientLight(0x222222);
  scene.add(light);

  // Your animation loop, which will run repeatedly and renders a new frame each time
  var animate = function () {
    requestAnimationFrame(animate);

    cube.rotation.x += 0.01;
    cube.rotation.y += 0.008;

    box.rotation.x -= 0.005;
    box.rotation.y += 0.007;
    box.rotation.z -= 0.011;
    
    cone.rotation.y += 0.02;

    torusKnot.rotation.x -= -0.00061;
    torusKnot.rotation.y += -0.001;
    torusKnot.rotation.z += -0.003;

    torusKnot2.rotation.x -= +0.001;
    torusKnot2.rotation.y += -0.005;
    torusKnot2.rotation.z += +0.01;

    ring1.rotation.x += 0.015

    ring2.rotation.x += 0.015
    ring2.rotation.y += 0.0317

    ring3.rotation.x += 0.015
    ring3.rotation.y += 0.0317
    ring3.rotation.x -= 0.00691

    renderer.render(scene, camera);
  };

  animate();
}


initialise_scene()
