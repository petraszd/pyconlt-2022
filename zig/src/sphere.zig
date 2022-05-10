const std = @import("std");
const sqrt = std.math.sqrt;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Ray = @import("ray.zig").Ray;
const Hit = @import("hit.zig").Hit;

pub const Sphere = struct {
    material: u32,
    center: Vec3,
    radius: f32,

    pub fn hitByRay(
        self: *const Sphere,
        ray: *const Ray,
        t_min: f32,
        t_max: f32,
        hit: *Hit,
    ) bool {
        const oc = ray.orig - self.center;
        const a = vec3.lenSquared(ray.dir);
        const half_b = vec3.dot(oc, ray.dir);
        const c = vec3.lenSquared(oc) - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;

        if (discriminant < 0.0) {
            return false;
        }

        const sqrt_discriminant = sqrt(discriminant);
        var root = (-half_b - sqrt_discriminant) / a;
        if (root < t_min or root > t_max) {
            root = (-half_b + sqrt_discriminant) / a;
            if (root < t_min or root > t_max) {
                return false;
            }
        }

        hit.t = root;
        hit.material = self.material;
        hit.point = ray.pointAtDistance(root);

        hit.normal = (hit.point - self.center) / vec3.toVec3(self.radius);

        hit.is_font_face = vec3.dot(ray.dir, hit.normal) < 0;
        if (!hit.is_font_face) {
            hit.normal *= vec3.toVec3(-1.0);
        }

        return true;
    }
};
