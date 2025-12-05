const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const d = 3;
    inline for (1..d) |day| {
        const day_str = std.fmt.comptimePrint("day{d:0>2}", .{day});
        const exe_mod = b.createModule(.{
            .root_source_file = b.path(std.fmt.comptimePrint("src/{s}/main.zig", .{day_str})),
            .target = target,
            .optimize = optimize,
        });
        const exe = b.addExecutable(.{
            .name = day_str,
            .root_module = exe_mod,
        });
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(day_str, std.fmt.comptimePrint("Run day {d}", .{day}));
        run_step.dependOn(&run_cmd.step);
    }
}
