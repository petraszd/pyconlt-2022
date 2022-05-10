from math import sqrt

from vec3 import dot, Vec3, length_squared
from hit import Hit


DEFAULT_HIT = Hit(
    point=Vec3(0.0, 0.0, 0.0),
    normal=Vec3(0.0, 0.0, 0.0),
    t=0.0,
    material=0,
)


class Sphere:
    def __init__(self, center, radius, material):
        self.center = center
        self.radius = radius
        self.material = material

    def hit_with_ray(self, ray, t_min, t_max):
        oc = ray.orig - self.center
        a = length_squared(ray.dir)
        half_b = dot(oc, ray.dir)
        c = length_squared(oc) - self.radius * self.radius
        discriminant = half_b * half_b - a * c

        if discriminant < 0.0:
            return False, DEFAULT_HIT

        sqrt_discriminant = sqrt(discriminant)
        root = (-half_b - sqrt_discriminant) / a
        if root < t_min or root > t_max:
            root = (-half_b + sqrt_discriminant) / a
            if root < t_min or root > t_max:
                return False, DEFAULT_HIT

        t = root
        point = ray.at(t)
        normal = (point - self.center) / self.radius
        is_font_face = dot(ray.dir, normal) < 0
        if not is_font_face:
            normal = normal * -1.0

        return True, Hit(
            t=root,
            point=ray.at(t),
            normal=normal,
            material=self.material,
        )
