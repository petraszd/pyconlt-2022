const Vec3 = @import("vec3.zig").Vec3;

pub const Ray = struct {
    orig: Vec3,
    dir: Vec3,

    pub inline fn pointAtDistance(self: *const Ray, distance: f32) Vec3 {
        return self.orig + (self.dir * @splat(3, distance));
    }
};
