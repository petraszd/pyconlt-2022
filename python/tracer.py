from random import random
from math import sqrt


# Vec3
# ----
class Vec3:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def __iter__(self):
        return iter((self.x, self.y, self.z))

    def __truediv__(self, num):
        return Vec3(self.x / num, self.y / num, self.z / num)

    def __mul__(self, num):
        return Vec3(self.x * num, self.y * num, self.z * num)

    def __rmul__(self, num):
        return Vec3(self.x * num, self.y * num, self.z * num)

    def __add__(self, v):
        return Vec3(self.x + v.x, self.y + v.y, self.z + v.z)

    def __sub__(self, v):
        return Vec3(self.x - v.x, self.y - v.y, self.z - v.z)


# Ray
# ---
class Ray:
    def __init__(self, orig, dir):
        self.orig = orig
        self.dir = dir

    def at(self, t):
        return self.orig + self.dir * t


# Hit
# ---
class Hit:
    def __init__(self, point, normal, t, material):
        self.point = point
        self.normal = normal
        self.t = t
        self.material = material


# Sphere
# ------

class Sphere:
    def __init__(self, center, radius, material):
        self.center = center
        self.radius = radius
        self.material = material


WIN_W, WIN_H = 320, 240
# WIN_W, WIN_H = 1200, 750
SAMPLES_PER_EDGE = 1
SAMPLES_PER_PIXEL = SAMPLES_PER_EDGE * SAMPLES_PER_EDGE
BACK_TOP_COLOR = Vec3(1.0, 1.0, 1.0)
BACK_BOTTOM_COLOR = Vec3(0.5, 0.7, 1.0)
NO_HIT_COLOR = Vec3(0.0, 0.0, 0.0)
MAX_DEPTH = 32
T_MIN = 0.001
T_MAX = 200.0

SPHERES = [
    Sphere(Vec3(0.55, 0.0, -1.5), 0.5, 0),
    Sphere(Vec3(-0.55, 0.0, -1.5), 0.5, 1),
    Sphere(Vec3(0.0, -100.5, -1.5), 100.0, 2),
]


def raytrace(arr):

    # Camera
    aspect_ratio = WIN_W / WIN_H
    viewport_height = 2.0
    viewport_width = aspect_ratio * viewport_height
    focal_length = 1.0

    origin = Vec3(0, 0, 0)
    horizontal = Vec3(viewport_width, 0, 0)
    vertical = Vec3(0, viewport_height, 0)
    lower_left_corner = (
        origin -
        horizontal / 2.0 -
        vertical / 2.0 -
        Vec3(0, 0, focal_length)
    )

    aa_dist = 1.0 / SAMPLES_PER_EDGE
    half_aa_dist = aa_dist / 2.0

    for y in range(WIN_H):
        if y % 10 == 0:
            print(f"Progress = {(y / (WIN_H - 1) * 100):6.02f}%", end="\r")

        for x in range(WIN_W):
            accum = Vec3(0.0, 0.0, 0.0)
            for i in range(SAMPLES_PER_PIXEL):
                delta_u = half_aa_dist + i % SAMPLES_PER_EDGE * aa_dist
                delta_v = half_aa_dist + i // SAMPLES_PER_EDGE * aa_dist

                v = (y + delta_u) / (WIN_H - 1.0)
                u = (x + delta_v) / (WIN_W - 1.0)

                ray_dir = unit(
                    lower_left_corner +
                    u * horizontal +
                    v * vertical -
                    origin
                )
                ray = Ray(orig=origin, dir=ray_dir)
                accum += ray_color(ray, MAX_DEPTH)

            r, g, b = accum
            scale = 1.0 / SAMPLES_PER_PIXEL
            r = sqrt(scale * r)
            g = sqrt(scale * g)
            b = sqrt(scale * b)

            arr[x, WIN_H - y - 1] = (
                int(r * 255) << 16 |
                int(g * 255) << 8 |
                int(b * 255) << 0
            )
    print("Progress = 100.00%")


def ray_color(ray, depth):
    if depth <= 0:
        return NO_HIT_COLOR

    is_hit, hit = hit_all_spheres(ray, T_MIN, T_MAX)
    if is_hit:
        # Material based reflection
        if hit.material == 0:
            new_ray = Ray(hit.point, reflect(hit.point, hit.normal))
        else:
            new_ray_dir = unit(
                hit.point + hit.normal + random_in_unit_sphere() - hit.point
            )
            new_ray = Ray(hit.point, new_ray_dir)

        result = ray_color(new_ray, depth - 1)

        # Material based color
        if hit.material == 1:
            result.x *= 0.2
            result.y *= 0.99
            result.z *= 0.2

        result *= 0.5
        return result

    # Sky
    t = 0.5 * (ray.dir.y + 1.0)
    return (1.0 - t) * BACK_TOP_COLOR + t * BACK_BOTTOM_COLOR


def hit_all_spheres(ray, t_min, t_max):
    closest = t_max
    is_any_hit = False
    closest_hit = None
    for sphere in SPHERES:
        is_hit, hit = hit_with_ray(sphere, ray, t_min, closest)
        if is_hit:
            closest_hit = hit
            closest = hit.t
            is_any_hit = True

    return is_any_hit, closest_hit


def unit(v):
    return v / length(v)


def length_squared(v):
    return v.x * v.x + v.y * v.y + v.z * v.z


def length(v):
    return sqrt(length_squared(v))


def dot(a, b):
    return a.x * b.x + a.y * b.y + a.z * b.z


def random_in_unit_sphere():
    result = Vec3(
        (random() - 0.5) * 2.0,
        (random() - 0.5) * 2.0,
        (random() - 0.5) * 2.0,
    )
    if length_squared(result) >= 1:
        result.x = (random() - 0.5) * 2.0
        result.y = (random() - 0.5) * 2.0
        result.z = (random() - 0.5) * 2.0
    return result


def reflect(v, normal):
    return unit(v - normal * 2.0 * dot(v, normal))


DEFAULT_HIT = Hit(
    point=Vec3(0.0, 0.0, 0.0),
    normal=Vec3(0.0, 0.0, 0.0),
    t=0.0,
    material=0,
)


def hit_with_ray(sphere, ray, t_min, t_max):
    oc = ray.orig - sphere.center
    a = length_squared(ray.dir)
    half_b = dot(oc, ray.dir)
    c = length_squared(oc) - sphere.radius * sphere.radius
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
    normal = (point - sphere.center) / sphere.radius
    is_font_face = dot(ray.dir, normal) < 0
    if not is_font_face:
        normal = normal * -1.0

    return True, Hit(
        t=root,
        point=ray.at(t),
        normal=normal,
        material=sphere.material,
    )
