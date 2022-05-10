const std = @import("std");
const math = std.math;
const Random = std.rand.Random;

pub const Vec3 = @Vector(3, f32);

pub inline fn toVec3(value: f32) Vec3 {
    return @splat(3, value);
}

pub inline fn dot(a: Vec3, b: Vec3) f32 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

pub inline fn lenSquared(v: Vec3) f32 {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
}

pub inline fn len(v: Vec3) f32 {
    return math.sqrt(lenSquared(v));
}

pub inline fn unit(v: Vec3) Vec3 {
    return v / toVec3(len(v));
}

pub inline fn randomInUnitSphere(rnd: *const Random) Vec3 {
    var result = Vec3{
        (rnd.float(f32) - 0.5) * 2.0,
        (rnd.float(f32) - 0.5) * 2.0,
        (rnd.float(f32) - 0.5) * 2.0,
    };
    while (lenSquared(result) >= 1) {
        result[0] = (rnd.float(f32) - 0.5) * 2.0;
        result[1] = (rnd.float(f32) - 0.5) * 2.0;
        result[2] = (rnd.float(f32) - 0.5) * 2.0;
    }
    return result;
}

pub inline fn reflect(a: Vec3, n: Vec3) Vec3 {
    return a - n * toVec3(2.0) * toVec3(dot(a, n));
}
