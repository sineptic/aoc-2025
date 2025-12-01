const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try load_input(allocator, 1);
    defer allocator.free(input);

    std.debug.print("day 1 part 1: {}\n", .{try day_1_part_1.run(input)});
    try day_1_part_2.run(allocator, input);
}

pub fn load_input(allocator: std.mem.Allocator, day: u8) ![]const u8 {
    assert(day > 0);
    const file_path = try std.fmt.allocPrint(allocator, "inputs/day-{}.txt", .{day});
    defer allocator.free(file_path);
    const content = try std.fs.cwd().readFileAlloc(allocator, file_path, 100_000);
    return content;
}

const day_1_part_1 = struct {
    const Rotation = struct {
        direction: Direction,
        steps: i16,

        const Direction = enum { left, right };
    };
    pub fn run(input: []const u8) !i64 {
        var lines = std.mem.splitScalar(u8, input, '\n');

        var position: i16 = 50;
        var count: usize = 0;
        while (lines.next()) |line| {
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
        }

        return @intCast(count);
    }
};
const day_1_part_2 = struct {
    const Rotation = struct {
        direction: Direction,
        steps: usize,

        const Direction = enum { left, right };
    };
    pub fn run(allocator: std.mem.Allocator, input: []const u8) !void {
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
            const steps = try std.fmt.parseInt(usize, remainder, 10);
            const rotation = Rotation{ .direction = direction, .steps = steps };
            try rotations.append(allocator, rotation);
        }

        var position: i16 = 50;
        var count: usize = 0;
        for (rotations.items) |rotation| {
            const steps: usize = @intCast(rotation.steps);
            for (0..steps) |_| {
                switch (rotation.direction) {
                    .left => {
                        position -= 1;
                    },
                    .right => {
                        position += 1;
                    },
                }
                position = @mod(position, 100);
                if (position == 0) {
                    count += 1;
                }
            }
        }
        std.debug.print("day 1 part 2: {}\n", .{count});
    }
};

test "day 1" {
    const gpa = std.testing.allocator;
    const input = try load_input(gpa, 1);
    defer gpa.free(input);

    const answer_1 = try day_1_part_1.run(input);
    try std.testing.expectEqual(1145, answer_1);

    const answer_2 = try day_1_part_2.run(gpa, input);
    try std.testing.expectEqual(6561, answer_2);
}

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
