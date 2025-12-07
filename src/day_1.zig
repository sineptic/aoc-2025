const std = @import("std");
const assert = std.debug.assert;

const utils = @import("utils.zig");

pub fn run1(input: []const u8) !i64 {
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
pub fn run2(input: []const u8) !i64 {
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
                const zeros_encountered = (utils.int_cast(u32, @mod(-position, 100)) + steps) / 100;
                const new_position = @mod(-utils.int_cast(i32, steps) + position, 100);

                position = new_position;
                count += zeros_encountered;
            },
            'R' => {
                const new_position = utils.int_cast(usize, position) + steps;
                count += new_position / 100;
                position = @intCast(@mod(new_position, 100));
            },
            else => unreachable,
        }
    }
    return @intCast(count);
}
