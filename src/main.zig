const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try load_input(allocator, 1);
    defer allocator.free(input);

    std.debug.print("day 1 part 1: {}\n", .{try day_1_part_1.run(input)});
    std.debug.print("day 1 part 2: {}\n", .{try day_1_part_2.run(input)});
}

pub fn load_input(allocator: std.mem.Allocator, day: u8) ![]const u8 {
    assert(day > 0);
    const file_path = try std.fmt.allocPrint(allocator, "inputs/day-{}.txt", .{day});
    defer allocator.free(file_path);
    const content = try std.fs.cwd().readFileAlloc(allocator, file_path, 100_000);
    return content;
}

pub fn int_cast(comptime T: type, int: anytype) T {
    return @as(T, @intCast(int));
}

const day_1_part_1 = struct {
    pub fn run(input: []const u8) !i64 {
        var lines = std.mem.splitScalar(u8, input, '\n');

        var position: i16 = 50;
        var count: usize = 0;
        while (lines.next()) |line| {
            if (line.len == 0) {
                continue;
            }
            const steps = try std.fmt.parseInt(i16, line[1..], 10);
            switch (line[0]) {
                'L' => {
                    position -= steps;
                    position = @mod(position, 100);
                },
                'R' => {
                    position += steps;
                    position = @mod(position, 100);
                },
                else => unreachable,
            }
            if (position == 0) {
                count += 1;
            }
        }
        return @intCast(count);
    }
};
const day_1_part_2 = struct {
    pub fn run(input: []const u8) !i64 {
        var lines = std.mem.splitScalar(u8, input, '\n');

        var position: i32 = 50;
        var count: usize = 0;
        while (lines.next()) |line| {
            assert(position >= 0 and position < 100);
            if (line.len == 0) {
                continue;
            }
            const steps = try std.fmt.parseInt(u32, line[1..], 10);
            switch (line[0]) {
                'L' => {
                    const zeros_encountered = (int_cast(u32, @mod(-position, 100)) + steps) / 100;
                    const new_position = @mod(-int_cast(i32, steps) + position, 100);

                    position = new_position;
                    count += zeros_encountered;
                },
                'R' => {
                    const new_position = int_cast(usize, position) + steps;
                    count += new_position / 100;
                    position = @intCast(@mod(new_position, 100));
                },
                else => unreachable,
            }
        }
        return @intCast(count);
    }
};

test "day 1" {
    const gpa = std.testing.allocator;
    const input = try load_input(gpa, 1);
    defer gpa.free(input);

    const answer_1 = try day_1_part_1.run(input);
    try std.testing.expectEqual(1145, answer_1);

    const answer_2 = try day_1_part_2.run(input);
    try std.testing.expectEqual(6561, answer_2);
}
