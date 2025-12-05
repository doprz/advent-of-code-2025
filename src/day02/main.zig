const std = @import("std");

const InvalidResult = struct {
    num: u64 = 0,
    sum: u64 = 0,
};

fn isInvalid(num: usize, allocator: std.mem.Allocator) !bool {
    const str = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(str);

    if (str.len & 1 != 0) return false;

    const s = str.len / 2;
    const lhs = str[0..s];
    const rhs = str[s..];

    return std.mem.eql(u8, lhs, rhs);
}

fn isInvalid2(num: usize, allocator: std.mem.Allocator) !bool {
    const str = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(str);

    for (1..str.len) |win_len| {
        if (str.len % win_len != 0) continue; // Divisible
        if (str.len / win_len < 2) continue; // Pattern repeats at least twice

        var window = std.mem.window(u8, str, win_len, win_len);
        const first = window.next() orelse unreachable;
        var all_match = true; // Assume all chunks match

        while (window.next()) |chunk| {
            if (!std.mem.eql(u8, first, chunk)) {
                all_match = false;
                break;
            }
        }

        return all_match;
    }

    return false;
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

    var p1 = InvalidResult{};
    var p2 = InvalidResult{};

    while (iter.peek()) |_| {
        const start_raw = iter.next() orelse unreachable;
        const end_raw = iter.next() orelse return error.BadInput;
        const start = try std.fmt.parseInt(u64, start_raw, 10);
        const end = try std.fmt.parseInt(u64, end_raw, 10);

        try stdout.print("Checking range {d}-{d}\n", .{ start, end });
        try stdout.flush();

        for (start..end + 1) |num| {
            if (try isInvalid(num, allocator)) {
                p1.num += 1;
                p1.sum += num;

                // try stdout.print("  Found invalid ID: {d}\n", .{num});
                // try stdout.flush();
            }

            if (try isInvalid2(num, allocator)) {
                p2.num += 1;
                p2.sum += num;

                try stdout.print("  Found invalid ID: {d}\n", .{num});
                try stdout.flush();
            }
        }
    }

    const parts = [_]*InvalidResult{ &p1, &p2 };

    for (parts, 0..) |p, i| {
        try stdout.print("Part {d}: ", .{i});
        try stdout.print("  Total invalid IDs found: {d}\n", .{p.num});
        try stdout.print("  Sum of all invalid IDs: {d}\n", .{p.sum});
    }
    try stdout.flush();
}
