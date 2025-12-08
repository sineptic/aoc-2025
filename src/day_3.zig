const std = @import("std");
const assert = std.debug.assert;

const utils = @import("utils");

pub fn run1(input: []const u8) u64 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var buf: [100]u8 = undefined;
    var answer: u64 = 0;
    while (lines.next()) |line| {
        assert(line.len >= 2);
        assert(line.len <= 100);
        @memset(&buf, 0);
        @memcpy(buf[0..line.len], line);
        const max_ix = std.mem.indexOfMax(u8, buf[0 .. line.len - 1]);
        const max1 = buf[max_ix] - '0';
        buf[max_ix] = 0;
        const max2 = std.mem.max(u8, buf[max_ix..line.len]) - '0';
        answer += max1 * 10 + max2;
    }
    return answer;
}

pub fn run2(input: []const u8) u64 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var buf: [100]u8 = undefined;
    var answer: u64 = 0;
    while (lines.next()) |line| {
        assert(line.len >= 2);
        assert(line.len <= 100);
        @memset(&buf, 0);
        @memcpy(buf[0..line.len], line);
        var number: u64 = 0;
        var search_start: usize = 0;
        for (1..13) |ix| {
            const remain = 12 - ix;
            const max_ix = std.mem.indexOfMax(u8, buf[search_start .. line.len - remain]) + search_start;
            search_start = max_ix + 1;
            const max = buf[max_ix] - '0';
            buf[max_ix] = 0;
            number = number * 10 + max;
        }
        answer += number;
    }
    return answer;
}
