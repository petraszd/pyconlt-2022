const Ray = @import("ray.zig").Ray;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;

pub const Camera = struct {
    orig: Vec3,
    lower_left: Vec3,
    hor: Vec3,
    ver: Vec3,

    pub fn makeRay(self: *const Camera, u: f32, v: f32) Ray {
        const dir: Vec3 = vec3.unit((self.lower_left +
            (self.hor * vec3.toVec3(u)) +
            (self.ver * vec3.toVec3(v)) -
            self.orig));

        return Ray{ .orig = self.orig, .dir = dir };
    }
};

pub fn makeCamera(w: u32, h: u32) Camera {
    const aspect_ratio = @intToFloat(f32, w) / @intToFloat(f32, h);
    const view_h: f32 = 2.0;
    const view_w: f32 = aspect_ratio * view_h;

    const focal_len: f32 = 1.0;
    const origin = Vec3{ 0.0, 0.0, 0.0 };
    const horizontal = Vec3{ view_w, 0.0, 0.0 };
    const vertical = Vec3{ 0.0, view_h, 0.0 };

    var lower_left: Vec3 = (origin -
        (horizontal * vec3.toVec3(0.5)) -
        (vertical * vec3.toVec3(0.5)) -
        Vec3{ 0.0, 0.0, focal_len });

    return Camera{
        .orig = origin,
        .lower_left = lower_left,
        .hor = horizontal,
        .ver = vertical,
    };
}
