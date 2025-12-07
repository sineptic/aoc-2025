const std = @import("std");
const assert = std.debug.assert;

const day_1 = @import("day_1.zig");
const day_2 = @import("day_2.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input1 = try utils.load_input(allocator, 1);
    defer allocator.free(input1);
    const input2 = try utils.load_input(allocator, 2);
    defer allocator.free(input2);

    // for (0..100) |_| {
    std.debug.print("day 1 part 1: {}\n", .{try day_1.run1(input1)});
    std.debug.print("day 1 part 2: {}\n", .{try day_1.run2(input1)});
    std.debug.print("day 2 part 1: {}\n", .{try day_2.run1(input2)});
    std.debug.print("day 2 part 2: {}\n", .{try day_2.run2(input2)});
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

    const a = try day_2.run2("121212-121213");
    try std.testing.expectEqual(121212, a);

    const answer_1 = try day_2.run1(input);
    try std.testing.expectEqual(40398804950, answer_1);

    const answer_2 = try day_2.run2(input);
    try std.testing.expectEqual(65794984339, answer_2);
}
