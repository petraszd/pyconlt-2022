const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;

pub const Hit = struct {
    point: Vec3,
    normal: Vec3,
    t: f32,
    is_font_face: bool,
    material: u32,
};
