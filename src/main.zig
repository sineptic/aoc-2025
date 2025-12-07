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

    // for (0..100) |_| {
    std.debug.print("day 1 part 1: {}\n", .{try day_1_part_1.run(input1)});
    std.debug.print("day 1 part 2: {}\n", .{try day_1_part_2.run(input1)});
    std.debug.print("day 2 part 1: {}\n", .{try day_2.run1(input2)});
    std.debug.print("day 2 part 2: {}\n", .{try day_2.run2(input2)});
    // }
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
        return run(input, solve_range1);
    }
    fn run2(input: []const u8) !u64 {
        return run(input, solve_range2);
    }

    fn run(input: []const u8, solve_range: fn ([]const u8, []const u8) u64) !u64 {
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
            result += solve_range(left_raw, right_raw);
        }
        return result;
    }
    fn solve_range1(left_raw: []const u8, right_raw: []const u8) u64 {
        assert(right_raw.len <= 10);

        var number_buffer: [10]u8 = undefined;
        @memcpy(number_buffer[0..left_raw.len], left_raw);

        const left = std.fmt.parseInt(u64, left_raw, 10) catch unreachable;
        const right = std.fmt.parseInt(u64, right_raw, 10) catch unreachable;

        var result: u64 = 0;
        var current_raw = number_buffer[0..left_raw.len];
        var current = left;
        while (current <= right) {
            if (@mod(current_raw.len, 2) != 0) {
                @memset(number_buffer[0..], '0');
                number_buffer[0] = '1';
                current_raw = number_buffer[0 .. current_raw.len + 1];
                current = std.math.pow(u64, 10, current_raw.len - 1);
                continue;
            }
            if (std.mem.eql(
                u8,
                current_raw[0 .. current_raw.len / 2],
                current_raw[current_raw.len / 2 .. current_raw.len],
            )) {
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
    const possible_chunk_sizes = [11][]const usize{
        &[_]usize{},
        &[_]usize{},
        &[_]usize{1},
        &[_]usize{1},
        &[_]usize{ 1, 2 },
        &[_]usize{1},
        &[_]usize{ 1, 2, 3 },
        &[_]usize{1},
        &[_]usize{ 1, 2, 4 },
        &[_]usize{ 1, 3 },
        &[_]usize{ 1, 2, 5 },
    };
    fn solve_range2(left_raw: []const u8, right_raw: []const u8) u64 {
        assert(right_raw.len <= 10);

        var number_buffer: [10]u8 = undefined;
        @memcpy(number_buffer[0..left_raw.len], left_raw);

        const left = std.fmt.parseInt(u64, left_raw, 10) catch unreachable;
        const right = std.fmt.parseInt(u64, right_raw, 10) catch unreachable;

        var result: u64 = 0;
        var current_raw = number_buffer[0..left_raw.len];
        var current = left;
        while (current <= right) {
            const possible_sizes = possible_chunk_sizes[current_raw.len];
            inner: for (possible_sizes) |size| {
                if (std.mem.eql(
                    u8,
                    current_raw[0 .. current_raw.len - size],
                    current_raw[size..current_raw.len],
                )) {
                    result += current;
                    break :inner;
                }
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

    const a = try day_2.run2("121212-121213");
    try std.testing.expectEqual(121212, a);

    const answer_1 = try day_2.run1(input);
    try std.testing.expectEqual(40398804950, answer_1);

    const answer_2 = try day_2.run2(input);
    try std.testing.expectEqual(65794984339, answer_2);
}
