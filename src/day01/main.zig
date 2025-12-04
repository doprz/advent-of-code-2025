const std = @import("std");

fn zeroCrossings(dir: u8, pos: i32, num: i32) u32 {
    if (pos == 0) return @intCast(@divFloor(num, 100));

    const steps_to_zero: i32 = if (dir == 'L') pos else 100 - pos;
    if (num < steps_to_zero) return 0;

    return @intCast(1 + @divFloor(num - steps_to_zero, 100));
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // NOTE: Using Zig 0.15.1 new IO interface
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const file = try std.fs.cwd().openFile("src/day01/input.txt", .{ .mode = .read_only });
    defer file.close();

    const file_size = (try file.stat()).size;
    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    var pos: i32 = 50;
    var part1: u32 = 0;
    var part2: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const dir = line[0];
        const num = try std.fmt.parseInt(i32, line[1..], 10);

        part2 += zeroCrossings(dir, pos, num);

        switch (dir) {
            'L' => {
                pos -= num;
            },
            'R' => {
                pos += num;
            },
            else => unreachable,
        }

        pos = @mod(pos, 100);
        if (pos == 0) part1 += 1;
    }

    try stdout.print("Hello Advent of Code 2025, Day 1!\n", .{});
    try stdout.print("Part 1 Password: {d}\n", .{part1});
    try stdout.print("Part 2 Password: {d}\n", .{part2});
    try stdout.flush();
}
