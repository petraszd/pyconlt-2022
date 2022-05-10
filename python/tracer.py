import time
from math import sqrt

from ray import Ray
from vec3 import Vec3, unit, random_in_unit_sphere, reflect
from sphere import Sphere


SAMPLES_PER_EDGE = 6
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


def raytrace(arr, w, h):
    start_time = time.time()

    # Camera
    aspect_ratio = w / h
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

    for y in range(h):
        if y % 10 == 0:
            print(f"Progress = {(y / (h - 1) * 100):6.02f}%", end="\r")

        for x in range(w):
            accum = Vec3(0.0, 0.0, 0.0)
            for i in range(SAMPLES_PER_PIXEL):
                delta_u = half_aa_dist + i % SAMPLES_PER_EDGE * aa_dist
                delta_v = half_aa_dist + i // SAMPLES_PER_EDGE * aa_dist

                v = (y + delta_u) / (h - 1.0)
                u = (x + delta_v) / (w - 1.0)

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

            arr[x, h - y - 1] = (
                int(r * 255) << 16 |
                int(g * 255) << 8 |
                int(b * 255) << 0
            )
    print("Progress = 100.00%")

    delta_time = time.time() - start_time
    print(f"Generation took {delta_time:.02f}s")


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
        is_hit, hit = sphere.hit_with_ray(ray, t_min, closest)
        if is_hit:
            closest_hit = hit
            closest = hit.t
            is_any_hit = True

    return is_any_hit, closest_hit
