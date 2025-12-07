const std = @import("std");
const assert = std.debug.assert;

const utils = @import("utils");

pub fn run1(input: []const u8) !u64 {
    return run(input, solve_range1);
}
pub fn run2(input: []const u8) !u64 {
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
