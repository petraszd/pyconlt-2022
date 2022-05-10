const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Executable
    const exe = b.addExecutable("raytracer", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkLibC();
    exe.addIncludeDir("/usr/local/include");
    exe.addLibPath("/usr/local/lib");
    exe.linkSystemLibrary("SDL2");
    exe.install();

    // Run command
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Library
    const lib = b.addSharedLibrary("raytracer", "src/tracer.zig", undefined);
    lib.setBuildMode(mode);
    lib.install();
}
