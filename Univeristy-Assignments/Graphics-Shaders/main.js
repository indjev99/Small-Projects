
// Add any resources you want to load here
// You will then be able to reference them in initialise_scene
// e.g. as "resources.vert_shader"
RESOURCES = [
  // format is:
  // ["name", "path-to-resource"]
  ["empty_vert_shader", "http://localhost:8000/shaders/empty.vert"],
  ["vert_shader", "http://localhost:8000/shaders/default.vert"],
  ["extended_vert_shader", "http://localhost:8000/shaders/extended.vert"],
  ["empty_frag_shader", "http://localhost:8000/shaders/empty.frag"],
  ["frag_shader", "http://localhost:8000/shaders/default.frag"],
  ["lighting_frag_shader", "http://localhost:8000/shaders/lighting.frag"],
  ["toon_frag_shader", "http://localhost:8000/shaders/toon.frag"],
  ["reflective_frag_shader", "http://localhost:8000/shaders/reflective.frag"]
]


/* Create the scene */

function initialise_scene(resources) {
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

  // Objects

  function emptyShader() {
    return new THREE.ShaderMaterial({
      vertexShader: resources["empty_vert_shader"],
      fragmentShader: resources["empty_frag_shader"]
    });
  };

  function defaultShader(r, g, b) {
    return new THREE.ShaderMaterial({
      uniforms: {
        color: {value: new THREE.Vector3(r, g, b)}
      },
      vertexShader: resources["vert_shader"],
      fragmentShader: resources["frag_shader"]
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
      vertexShader: resources["extended_vert_shader"],
      fragmentShader: resources["reflective_frag_shader"]
    });
  };

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
  sphere.position.set(-35, -15, -50);
  scene.add(sphere);

  geometry = new THREE.SphereGeometry(3, 1024, 1024);
  material = reflectiveMaterial(0.3, 0.6, 0.4, 0.3, 1.0);
  r_sphere = new THREE.Mesh(geometry, material);
  r_sphere.position.set(1, -13, 0);
  scene.add(r_sphere);

  geometry = new THREE.TorusGeometry(8, 0.75, 1024, 1024);
  material = toonMaterial(1.0, 0.0, 0.0, 2.0);
  ring1 = new THREE.Mesh(geometry, material);
  ring1.position.set(15, -15, -10);
  scene.add(ring1);

  geometry = new THREE.TorusGeometry(5, 0.75, 1024, 1024);
  material = toonMaterial(0.0, 1.0, 0.0, 3.0);
  ring2 = new THREE.Mesh(geometry, material);
  ring2.position.set(15, -15, -10);
  scene.add(ring2);

  geometry = new THREE.TorusGeometry(2, 0.75, 1024, 1024);
  material = toonMaterial(0.0, 0.0, 1.0, 4.0);
  ring3 = new THREE.Mesh(geometry, material);
  ring3.position.set(15, -15, -10);
  scene.add(ring3);

  geometry = new THREE.TorusKnotGeometry(3, 0.5, 1024, 1024);
  material = new THREE.MeshPhysicalMaterial({ color: 0xaf00ff });
  material.clearcoat = 1.0;
  torusKnot = new THREE.Mesh(geometry, material);
  torusKnot.position.set(0, 10, 0);
  scene.add(torusKnot);

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


/*  Asynchronously load resources

    You shouldn't need to change this - you can add
    more resources by changing RESOURCES above */

function load_resources() {
  var promises = []

  for(let r of RESOURCES) {
    promises.push(fetch(r[1], {
      mode: 'no-cors'
    })
    .then(res => res.text()))
  }

  return Promise.all(promises).then(function(res) {
    let resources = {}
    for(let i in RESOURCES) {
      resources[RESOURCES[i][0]] = res[i]
    }
    return resources
  })
}

// Load the resources and then create the scene when resources are loaded
load_resources().then(res => initialise_scene(res))
