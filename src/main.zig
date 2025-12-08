const std = @import("std");
const assert = std.debug.assert;

const day_1 = @import("day_1.zig");
const day_2 = @import("day_2.zig");
const day_3 = @import("day_3.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input1 = try utils.load_input(allocator, 1);
    defer allocator.free(input1);
    const input2 = try utils.load_input(allocator, 2);
    defer allocator.free(input2);
    const input3 = try utils.load_input(allocator, 3);
    defer allocator.free(input3);

    // for (0..100) |_| {
    std.debug.print("day 1 part 1: {}\n", .{try day_1.run1(input1)});
    std.debug.print("day 1 part 2: {}\n", .{try day_1.run2(input1)});
    std.debug.print("day 2 part 1: {}\n", .{day_2.run1(input2)});
    std.debug.print("day 2 part 2: {}\n", .{day_2.run2(input2)});
    std.debug.print("day 3 part 1: {}\n", .{day_3.run1(input3)});
    std.debug.print("day 3 part 2: {}\n", .{day_3.run2(input3)});
    // }
}

test "day_1" {
    const gpa = std.testing.allocator;
    const input = try utils.load_input(gpa, 1);
    defer gpa.free(input);

    const answer_1 = try day_1.run1(input);
    try std.testing.expectEqual(1145, answer_1);

    const answer_2 = try day_1.run2(input);
    try std.testing.expectEqual(6561, answer_2);
}

test "day_2" {
    const gpa = std.testing.allocator;
    const input = try utils.load_input(gpa, 2);
    defer gpa.free(input);

    try std.testing.expectEqual(121212, day_2.run2("121212-121213"));

    try std.testing.expectEqual(40398804950, day_2.run1(input));

    try std.testing.expectEqual(65794984339, day_2.run2(input));
}

test "day_3" {
    const gpa = std.testing.allocator;
    const example_input = try utils.load_example_input(gpa, 3);
    defer gpa.free(example_input);
    const input = try utils.load_input(gpa, 3);
    defer gpa.free(input);

    try std.testing.expectEqual(357, day_3.run1(example_input));
    try std.testing.expectEqual(17435, day_3.run1(input));

    try std.testing.expectEqual(3121910778619, day_3.run2(example_input));
    try std.testing.expectEqual(172886048065379, day_3.run2(input));
}
