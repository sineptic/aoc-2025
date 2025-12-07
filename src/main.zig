const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input1 = try load_input(allocator, 1);
    defer allocator.free(input1);
    const input2 = try load_input(allocator, 2);
    defer allocator.free(input2);

    std.debug.print("day 1 part 1: {}\n", .{try day_1_part_1.run(input1)});
    std.debug.print("day 1 part 2: {}\n", .{try day_1_part_2.run(input1)});
    std.debug.print("day 2 part 1: {}\n", .{try day_2.run1(input2)});
    std.debug.print("day 2 part 2: {}\n", .{try day_2.run2(input2)});
}

pub fn load_input(allocator: std.mem.Allocator, day: u8) ![]const u8 {
    assert(day > 0);
    const file_path = try std.fmt.allocPrint(allocator, "inputs/day-{}.txt", .{day});
    defer allocator.free(file_path);
    const content = try std.fs.cwd().readFileAlloc(allocator, file_path, 100_000);
    return content;
}
pub fn load_example_input(allocator: std.mem.Allocator, day: u8) ![]const u8 {
    assert(day > 0);
    const file_path = try std.fmt.allocPrint(allocator, "inputs/day-{}-example.txt", .{day});
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
const day_2 = struct {
    fn run1(input: []const u8) !u64 {
        return run(input, is_repeated1);
    }
    fn run2(input: []const u8) !u64 {
        return run(input, is_repeated2);
    }

    fn run(input: []const u8, is_repeated: fn ([]const u8) bool) !u64 {
        const mb_line_end = std.mem.indexOfScalar(u8, input, '\n');
        const first_line = a: {
            if (mb_line_end) |line_end| {
                break :a input[0..line_end];
            } else {
                break :a input;
            }
        };
        var ranges = std.mem.splitScalar(u8, first_line, ',');

        var result: u64 = 0;
        while (ranges.next()) |range| {
            const dash_pos = std.mem.indexOfScalar(u8, range, '-') orelse unreachable;
            const left_raw = range[0..dash_pos];
            const right_raw = range[dash_pos + 1 ..];
            result += solve_range(left_raw, right_raw, is_repeated);
        }
        return result;
    }
    fn solve_range(left_raw: []const u8, right_raw: []const u8, is_repeated: fn ([]const u8) bool) u64 {
        var number_buffer: [1000]u8 = undefined;
        @memcpy(number_buffer[0..left_raw.len], left_raw);

        const left = std.fmt.parseInt(u64, left_raw, 10) catch unreachable;
        const right = std.fmt.parseInt(u64, right_raw, 10) catch unreachable;

        var result: u64 = 0;
        var current_raw = number_buffer[0..left_raw.len];
        var current = left;
        while (current <= right) {
            if (is_repeated(current_raw)) {
                result += current;
            }

            current += 1;
            const fit = increment(current_raw);
            if (!fit) {
                @memset(number_buffer[0..], '0');
                number_buffer[0] = '1';
                current_raw = number_buffer[0 .. current_raw.len + 1];
            }
        }
        return result;
    }
    fn increment(number: []u8) bool {
        switch (number[number.len - 1]) {
            '0'...'8' => {
                number[number.len - 1] += 1;
                return true;
            },
            '9' => {
                if (number.len <= 1) {
                    return false;
                }
                number[number.len - 1] = '0';
                return increment(number[0 .. number.len - 1]);
            },
            else => unreachable,
        }
    }
    fn is_repeated1(number: []const u8) bool {
        const length = number.len / 2;
        if (number.len != length * 2) {
            return false;
        }
        return std.mem.eql(
            u8,
            number[0 .. number.len - length],
            number[length..number.len],
        );
    }
    fn is_repeated2(number: []const u8) bool {
        for (1..number.len / 2 + 1) |length| {
            if (std.mem.eql(
                u8,
                number[0 .. number.len - length],
                number[length..number.len],
            )) {
                return @mod(number.len, length) == 0;
            }
        }
        return false;
    }
};

test "day_1" {
    const gpa = std.testing.allocator;
    const input = try load_input(gpa, 1);
    defer gpa.free(input);

    const answer_1 = try day_1_part_1.run(input);
    try std.testing.expectEqual(1145, answer_1);

    const answer_2 = try day_1_part_2.run(input);
    try std.testing.expectEqual(6561, answer_2);
}

test "day_2" {
    const gpa = std.testing.allocator;
    const input = try load_input(gpa, 2);
    defer gpa.free(input);

    const answer_1 = try day_2.run1(input);
    try std.testing.expectEqual(40398804950, answer_1);

    const answer_2 = try day_2.run2(input);
    try std.testing.expectEqual(65794984339, answer_2);
}
