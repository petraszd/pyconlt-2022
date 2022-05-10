from random import random
from math import sqrt


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
