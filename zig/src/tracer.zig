const std = @import("std");
const vec3 = @import("vec3.zig");
const Ray = @import("ray.zig").Ray;
const Hit = @import("hit.zig").Hit;
const Sphere = @import("sphere.zig").Sphere;
const makeCamera = @import("camera.zig").makeCamera;
const Vec3 = vec3.Vec3;
const toVec3 = vec3.toVec3;

const MAX_DISTANCE_FROM_CAMERA: f32 = 200.0;
const COLOR_SKY_TOP: Vec3 = Vec3{ 1.0, 1.0, 1.0 };
const COLOR_SKY_BOTTOM: Vec3 = Vec3{ 0.5, 0.7, 1.0 };
const SAMPLES_PER_EDGE = 6;
const SAMPLES_PER_PIXEL = SAMPLES_PER_EDGE * SAMPLES_PER_EDGE;
const MAX_DEPTH = 32;

const spheres = [_]Sphere{
    Sphere{ .center = Vec3{ 0.55, 0.0, -1.5 }, .radius = 0.5, .material = 0 },
    Sphere{ .center = Vec3{ -0.55, 0.0, -1.5 }, .radius = 0.5, .material = 1 },
    Sphere{ .center = Vec3{ 0.0, -100.5, -1.5 }, .radius = 100.0, .material = 2 },
};

pub export fn drawFrame(pixels: [*]u8, w: u32, h: u32) void {
    const half_w = w / 2;
    const half_h = h / 2;

    const t1 = std.Thread.spawn(.{}, drawFramePortion, .{ pixels, 0, w, h, 0, half_w, 0, half_h }) catch null;
    const t2 = std.Thread.spawn(.{}, drawFramePortion, .{ pixels, 1, w, h, half_w, w, 0, half_h }) catch null;
    const t3 = std.Thread.spawn(.{}, drawFramePortion, .{ pixels, 2, w, h, 0, half_w, half_h, h }) catch null;
    const t4 = std.Thread.spawn(.{}, drawFramePortion, .{ pixels, 3, w, h, half_w, w, half_h, h }) catch null;

    if (t1) |t| {
        defer t.join();
    }
    if (t2) |t| {
        defer t.join();
    }
    if (t3) |t| {
        defer t.join();
    }
    if (t4) |t| {
        defer t.join();
    }
}

pub fn drawFramePortion(pixels: [*]u8, idx: u32, w: u32, h: u32, x0: u32, x1: u32, y0: u32, y1: u32) void {
    std.log.info("[TRACER {}] drawFramePortion.start", .{idx});
    defer std.log.info("[TRACER {}] drawFramePortion.end", .{idx});

    const camera = makeCamera(w, h);
    var rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())).random();
    const subsample_distance: f32 = 1.0 / @intToFloat(f32, SAMPLES_PER_EDGE);
    const half_subsample_distance: f32 = subsample_distance / 2.0;

    var y: usize = y0;
    while (y < y1) {
        if (y % 50 == 0 or y == y1 - 1) {
            std.log.info("[TRACER {}] generating {d:.2}%", .{ idx, @intToFloat(f32, y - y0) / @intToFloat(f32, y1 - y0 - 1) * 100.0 });
        }

        var x: usize = x0;
        while (x < x1) {
            var color: Vec3 = Vec3{ 0.0, 0.0, 0.0 };

            var i: usize = 0;
            while (i < SAMPLES_PER_PIXEL) {
                const delta_u = half_subsample_distance + @intToFloat(f32, i % SAMPLES_PER_EDGE) * subsample_distance;
                const delta_v = half_subsample_distance + @intToFloat(f32, i / SAMPLES_PER_EDGE) * subsample_distance;
                const u: f32 = (@intToFloat(f32, x) + delta_u) / @intToFloat(f32, w - 1);
                const v: f32 = (@intToFloat(f32, y) + delta_v) / @intToFloat(f32, h - 1);

                const ray: Ray = camera.makeRay(u, v);
                color += rayColor(&ray, &rnd, MAX_DEPTH);
                i += 1;
            }

            const scale: f32 = 1.0 / @intToFloat(f32, SAMPLES_PER_PIXEL);

            const r = std.math.sqrt(scale * color[0]);
            const g = std.math.sqrt(scale * color[1]);
            const b = std.math.sqrt(scale * color[2]);

            pixels[(h - y - 1) * w * 4 + x * 4 + 0] = @floatToInt(u8, 255.0 * b);
            pixels[(h - y - 1) * w * 4 + x * 4 + 1] = @floatToInt(u8, 255.0 * g);
            pixels[(h - y - 1) * w * 4 + x * 4 + 2] = @floatToInt(u8, 255.0 * r);
            pixels[(h - y - 1) * w * 4 + x * 4 + 3] = 255;

            x += 1;
        }
        y += 1;
    }
}

fn rayColor(ray: *const Ray, rnd: *const std.rand.Random, depth: i32) Vec3 {
    if (depth <= 0) {
        return Vec3{ 0.0, 0.0, 0.0 };
    }

    var hit: Hit = Hit{
        .point = Vec3{ 0.0, 0.0, 0.0 },
        .normal = Vec3{ 0.0, 0.0, 0.0 },
        .t = 0.0,
        .is_font_face = false,
        .material = 0,
    };

    var isHit = hitAllObjects(ray, 0.001, MAX_DISTANCE_FROM_CAMERA, &hit);
    if (isHit) {
        var result: Vec3 = undefined;

        if (hit.material == 0) {
            var dir: Vec3 = vec3.reflect(hit.point, hit.normal);
            const new_ray: Ray = Ray{
                .orig = hit.point,
                .dir = dir,
            };
            result = rayColor(&new_ray, rnd, depth - 1);
        } else {
            const dir: Vec3 = vec3.unit(hit.point +
                hit.normal +
                vec3.randomInUnitSphere(rnd) -
                hit.point);
            const new_ray: Ray = Ray{
                .orig = hit.point,
                .dir = dir,
            };
            result = rayColor(&new_ray, rnd, depth - 1);
        }

        // Colors
        switch (hit.material) {
            0 => {
                result[0] *= 1.0;
                result[1] *= 1.0;
                result[2] *= 1.0;
            },
            1 => {
                result[0] *= 0.2;
                result[1] *= 0.99;
                result[2] *= 0.2;
            },
            2 => {
                result[0] *= 1.0;
                result[1] *= 1.0;
                result[2] *= 1.0;
            },
            else => {},
        }
        result *= toVec3(0.5);

        return result;
    }

    var t: f32 = 0.5 * (ray.dir[1] + 1.0);
    return COLOR_SKY_TOP * toVec3(1.0 - t) + COLOR_SKY_BOTTOM * toVec3(t);
}

fn hitAllObjects(ray: *const Ray, t_min: f32, t_max: f32, hit: *Hit) bool {
    var isHit: bool = false;
    var closest: f32 = t_max;
    for (spheres) |sphere| {
        if (sphere.hitByRay(ray, t_min, closest, hit)) {
            closest = hit.t;
            isHit = true;
        }
    }
    return isHit;
}
