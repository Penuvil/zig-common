const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = std.fs.path.basename(b.pathFromRoot(".")),
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    if (optimize == .Debug) exe.strip = false;
    exe.install();

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) run_cmd.addArgs(b.args.?);
    b.step("run", "Run the app").dependOn(&run_cmd.step);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.step("test", "Run unit tests").dependOn(&b.addRunArtifact(tests).step);
}
