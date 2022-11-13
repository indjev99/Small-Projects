import math
from collections import namedtuple

RayIntersection = namedtuple('RayIntersection', 'origin direction renderable location length')

class vec3:
    def __init__(self,x,y=None,z=None):
        if y is None and z is None:
            y = x
            z = x
        self.x = x
        self.y = y
        self.z = z

    def __sub__(self,p):
        return vec3(self.x-p.x,self.y-p.y,self.z-p.z)

    def __add__(self,p):
        return vec3(self.x+p.x,self.y+p.y,self.z+p.z)

    def __mul__(self,k):
        return vec3(self.x*k,self.y*k,self.z*k)

    def __truediv__(self,k):
        return self * (1/k)

    def __radd__(self, p): return self + p
    def __rmul__(self, p): return self * p

    def dot(self, p):
        return self.x*p.x + self.y*p.y + self.z*p.z

    def cross(self, p):
        return vec3(self.y*p.z - self.z*p.y, self.z*p.x - self.x*p.z, self.x*p.y - self.y*p.x)

    def len(self):
        return math.sqrt(self.dot(self))

    def len_squared(self):
        return self.dot(self)

    def norm(self):
        return self / self.len()

    def __repr__(self):
        return f"vec3({self.x}, {self.y}, {self.z})"

    def clamp(self, a, b):
        return vec3(
            min(b, max(a, self.x)),
            min(b, max(a, self.y)),
            min(b, max(a, self.z)),
        )