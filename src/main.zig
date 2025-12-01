const std = @import("std");

const Rotation = struct {
    direction: Direction,
    steps: i16,

    const Direction = enum { left, right };
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try std.fs.cwd().readFileAlloc(allocator, "inputs/day-1-part-1.txt", 100_000);
    defer allocator.free(input);

    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var lines = std.ArrayList([]const u8).empty;
    defer lines.deinit(allocator);
    while (lines_iter.next()) |line| {
        try lines.append(allocator, line);
    }

    var rotations = std.ArrayList(Rotation).empty;
    defer rotations.deinit(allocator);
    for (lines.items) |line| {
        if (line.len == 0) {
            continue;
        }
        const direction_letter = line[0];
        const direction = a: switch (direction_letter) {
            'L' => {
                break :a Rotation.Direction.left;
            },
            'R' => {
                break :a Rotation.Direction.right;
            },
            else => {
                std.debug.panic("unexpected first character in line: {c}", .{direction_letter});
            },
        };
        const remainder = line[1..];
        const steps = try std.fmt.parseInt(i16, remainder, 10);
        const rotation = Rotation{ .direction = direction, .steps = steps };
        try rotations.append(allocator, rotation);
    }

    var position: i16 = 50;
    var count: usize = 0;
    for (rotations.items) |rotation| {
        // std.debug.print("{}\n", .{rotation});
        switch (rotation.direction) {
            .left => {
                position -= rotation.steps;
            },
            .right => {
                position += rotation.steps;
            },
        }
        position = @mod(position, 100);
        if (position == 0) {
            count += 1;
        }

        // std.debug.print("\n", .{});
    }
    std.debug.print("password: {}", .{count});
}

// test "simple test" {
//     const gpa = std.testing.allocator;
//     var list: std.ArrayList(i32) = .empty;
//     defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(gpa, 42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }

// test "fuzz example" {
//     const Context = struct {
//         fn testOne(context: @This(), input: []const u8) anyerror!void {
//             _ = context;
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }
