from PIL import Image
import math

from helpers import *

class Material:
    def __init__(self, spec_coeff, diff_coeff, shininess):
        self.spec_coeff = spec_coeff
        self.diff_coeff = diff_coeff
        self.shininess = shininess

#
#   Renderables
#

EPS = 0.00001

class Renderable:
    def __init__(self, material):
        if not material:
            material = Material(0.75, 0.9, 4)
        self.material = material

    # Should return a RayIntersection for the intersection between
    # the ray from origin with direction
    def intersect(self, origin, direction): pass

    # Should return the normal at the given location
    def normal(self, location): pass

class Sphere(Renderable):
    def __init__(self, origin, radius, material=None):
        Renderable.__init__(self, material)
        self.origin = origin
        self.radius = radius

    # origin (vec3) represents the start of the ray
    # direction (vec3) represents the direction of the ray
    #
    # should return a RayIntersection representing the point where
    # the input ray intersects the sphere
    def intersect(self, origin, direction):
        cntr_org = self.origin - origin
        dir_dot_co = direction.dot(cntr_org)
        det = dir_dot_co ** 2 - cntr_org.len_squared() + self.radius ** 2
        if det < 0:
            return None
        
        ray_length = dir_dot_co - math.sqrt(det)
        if ray_length < EPS:
            return None
        
        intersection = origin + ray_length * direction
        return RayIntersection(origin, direction, self, intersection, ray_length)

    # location (vec3) is a point on the sphere
    # 
    # should return a vec3 representing the normal at that point
    def normal(self, location):
        normal = (location - self.origin).norm()
        return normal

class Triangle(Renderable):
    def __init__(self, vert0, vert1, vert2, material=None):
        Renderable.__init__(self, material)
        self.vert0 = vert0
        self.vert1 = vert1
        self.vert2 = vert2
        self.edge1 = vert1 - vert0
        self.edge2 = vert2 - vert0
        self.norm = self.edge1.cross(self.edge2).norm()

    # origin (vec3) represents the start of the ray
    # direction (vec3) represents the direction of the ray
    #
    # should return a RayIntersection representing the point where
    # the input ray intersects the sphere
    def intersect(self, origin, direction):
        pvec = direction.cross(self.edge2)
        det = pvec.dot(self.edge1)

        if (det < EPS):
            return None
        
        inv_det = 1 / det
        tvec = origin - self.vert0
        u = inv_det * tvec.dot(pvec)
        
        if (u < 0 or u > 1):
            return None
        
        qvec = tvec.cross(self.edge1)
        v = inv_det * direction.dot(qvec)

        if (v < 0 or u + v > 1):
            return None
        
        ray_length = inv_det * qvec.dot(self.edge2)

        if (ray_length < EPS):
            return None
        
        intersection = origin + ray_length * direction
        return RayIntersection(origin, direction, self, intersection, ray_length)

    # location (vec3) is a point on the sphere
    # 
    # should return a vec3 representing the normal at that point
    def normal(self, location):
        return self.norm

#
#   Lights
#

class Light:
    def __init__(self, pos, colour=None):
        self.position = pos
        self.colour = colour if colour else vec3(1)

    # return the colour of renderable at location according to 
    # renderer's camera
    def illumination(self, renderable, location, renderer):
        return self.colour

class PhongLight(Light):
    def __init__(self, pos, specular=None, diffuse=None):
        self.position = pos
        self.specular = specular if specular else vec3(1)
        self.diffuse = diffuse if diffuse else vec3(1)

    # renderable (Renderable) is the object being lit
    # location (vec3) is the point on the object
    # renderer (Renderer) is a reference to the renderer
    #
    # should return a vec3 (red, green, blue) of the colour
    # and brightness that the point is illuminated to by
    # this light (each colour channel should be 0-1)
    def illumination(self, renderable, location, renderer):
        l_dist = (self.position - location).len()
        l_dir = (self.position - location).norm()

        result = renderer.raycast(location, l_dir, [renderable])
        if result and result.length < l_dist:
            return vec3(0, 0, 0)

        normal = renderable.normal(location)
        r_dir = 2 * l_dir.dot(normal) * normal - l_dir
        view = (renderer.camera - self.position).norm()

        mat = renderable.material
        diff = mat.diff_coeff * max(0, normal.dot(l_dir))
        spec = mat.spec_coeff * max(0, view.dot(r_dir)) ** mat.shininess

        col = diff * self.diffuse + spec * self.specular
        col = col.clamp(0, 1)
        return col

#
#   Renderer
#

class Renderer:
    def __init__(self):
        self.camera = vec3(0, 0, 0)
        self.lights = []
        self.renderables = []

    # origin (vec3) and direction (vec3) describe the ray
    # exclude (list) is a list of renderables to ignore
    #
    # returns the nearest intersection between the ray
    # and any renderables
    def raycast(self, origin, direction, exclude=None):
        if not exclude: exclude = []

        d_norm = direction.norm()
        intersections = [
            r.intersect(origin, d_norm)
            for r in self.renderables
            if r not in exclude
        ]
        intersections = [r for r in intersections if r]
        if not intersections: return None
        return min(intersections, key=lambda x:x.length)

    # ray_intersection (RayIntersection) is an intersection
    #
    # should return the colour (vec3) at that intersection
    def get_lighting(self, ray_intersection):
        output = vec3(0)

        for light in self.lights:
            output += light.illumination(ray_intersection.renderable, ray_intersection.location, self)

        # return output / len(self.lights)
        return output.clamp(0, 1)

    def sample(self, x, y):
        result = self.raycast(
            self.camera,
            vec3(x, y, 1)
        )

        if result:
            return self.get_lighting(result)
        else:
            return vec3(1, 1, 1)
    
    # x (int), y (int), screen coordinates
    # width (int), height (int), screen size
    #
    # should return the colour of the pixel at
    # x,y on a screen of width x height
    def render(self, x, y, width, height, antialias=1):
        lighting = vec3(0, 0, 0)
        for dx in range(antialias):
            for dy in range(antialias):
                curr_x = x + (0.5 + dx) / antialias
                curr_y = y + (0.5 + dy) / antialias
                lighting += self.sample(curr_x / width - 0.5, curr_y / height - 0.5)
        lighting /= antialias ** 2
        return (int(lighting.x * 255), int(lighting.y * 255), int(lighting.z * 255))

if __name__ == '__main__':
    #
    #   Scene is described here
    #

    width = 2**10
    height = 2**10

    img = Image.new( 'RGB', (width,height), "black")
    pixels = img.load()

    renderer = Renderer()
    renderer.lights = [
        PhongLight(vec3(-2, 5, -8), vec3(1, 1, 1), vec3(0, 0, 0.8)),
        PhongLight(vec3(-10, -10, 30), vec3(0.6, 0, 0), vec3(0.9, 0, 0)),
        PhongLight(vec3(10, 0, 7), vec3(0, 0.7, 0.7), vec3(0, 0.4, 0))
    ]
    renderer.renderables = [
        Sphere(vec3(2, -1, 12), 4),
        Sphere(vec3(-1, 1.5, 6), 1.5),
        Sphere(vec3(2, 0, 5), 0.5)
    ]

    for i in range(img.size[0]):
        print(f"Rendering column ({i}/{img.size[0]})")
        for j in range(img.size[1]):
            pixels[i, j] = renderer.render(i, j, width, height, 2)

    img.save('output.png')