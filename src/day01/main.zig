const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello Advent of Code 2025, Day 1!\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("src/day01/input.txt", .{ .mode = .read_only });
    defer file.close();

    // NOTE: Using Zig 0.15.1 new IO interface
    var read_buffer: [256]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&read_buffer);

    const reader = &file_reader.interface;
    var line = std.Io.Writer.Allocating.init(alloc);
    defer line.deinit();

    var position: i32 = 50;
    var zero_count: u32 = 0;

    while (true) {
        _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
            if (err == error.EndOfStream) break else return err;
        };
        _ = reader.toss(1); // Skip the delimiter

        const l: []u8 = line.written();
        const dir = l[0];
        const dist = try std.fmt.parseInt(i32, l[1..], 10);

        position = if (dir == 'L') @mod(position - dist, 100) else @mod(position + dist, 100);
        if (position == 0) zero_count += 1;

        line.clearRetainingCapacity(); // Reset the accumulating buffer
    }

    std.debug.print("Password: {d}\n", .{zero_count});
}
