const std = @import("std");

fn isInvalid(num: usize, allocator: std.mem.Allocator) !bool {
    const str = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(str);

    if (str.len & 1 != 0) return false;

    const s = str.len / 2;
    const lhs = str[0..s];
    const rhs = str[s..];

    return std.mem.eql(u8, lhs, rhs);
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Hello Advent of Code 2025, Day 2!\n", .{});
    try stdout.flush();

    const file = try std.fs.cwd().openFile("src/day02/input.txt", .{ .mode = .read_only });
    defer file.close();

    const file_size = (try file.stat()).size;
    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    const line = std.mem.trim(u8, content, "\n");
    var iter = std.mem.splitAny(u8, line, "-,");

    var total_invalid: u64 = 0;
    var invalid_sum: u64 = 0;

    while (iter.peek()) |_| {
        const start_raw = iter.next() orelse unreachable;
        const end_raw = iter.next() orelse return error.BadInput;
        const start = try std.fmt.parseInt(u64, start_raw, 10);
        const end = try std.fmt.parseInt(u64, end_raw, 10);

        try stdout.print("Checking range {d}-{d}\n", .{ start, end });
        try stdout.flush();

        for (start..end + 1) |num| {
            if (try isInvalid(num, allocator)) {
                total_invalid += 1;
                invalid_sum += num;

                try stdout.print("  Found invalid ID: {d}\n", .{num});
                try stdout.flush();
            }
        }
    }

    try stdout.print("Total invalid IDs found: {d}\n", .{total_invalid});
    try stdout.print("Sum of all invalid IDs: {d}\n", .{invalid_sum});
    try stdout.flush();
}
