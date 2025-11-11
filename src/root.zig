const std = @import("std");

const Token = struct {
    token_type: TokenType,
};

const TokenType = union(enum) {
    keyword: Keyword,
    identifier,
    literal: Literal,
    operator: Operator,
    delimiter: Delimiter,
    special: Special,
};

const Keyword = enum {
    control_flow,
    type_decl,
    modifier,
    logic,
};

const Literal = enum {
    integer,
    float,
    string,
    character,
    boolean,
    none,
};

const Operator = enum {
    arithmetic,
    comparison,
    logical,
    bitwise,
    assignment,
    unary,
    ternary,
    other,
};

const Delimiter = enum {
    bracket,
    separator,
    arrow,
};

const Special = enum {
    eof,
    newline,
    indent,
};

fn tokenize(buffer: []const u8, delimiters: []const u8) TokenIterator {
    return .{
        .index = 0,
        .buffer = buffer,
        .delimiter = delimiters,
    };
}

const TokenIterator = struct {
    buffer: []const u8,
    delimiter: []const u8,
    index: usize,

    const Self = @This();

    pub fn next(self: *Self) ?[]const u8 {
        const result = self.peek() orelse return null;
        self.index += result.len;
        return result;
    }

    pub fn peek(self: *Self) ?[]const u8 {
        while (self.index < self.buffer.len and self.isDelimiter(self.index)) : (self.index += 1) {}
        const start = self.index;
        if (start == self.buffer.len) {
            return null;
        }

        var end = start;
        while (end < self.buffer.len and !self.isDelimiter(end)) : (end += 1) {}

        return self.buffer[start..end];
    }

    pub fn rest(self: Self) []const u8 {
        var index: usize = self.index;
        while (index < self.buffer.len and self.isDelimiter(index)) : (index += 1) {}
        return self.buffer[index..];
    }

    pub fn reset(self: *Self) void {
        self.index = 0;
    }

    fn isDelimiter(self: Self, index: usize) bool {
        const item = self.buffer[index];
        for (self.delimiter) |delimiter_item| {
            if (item == delimiter_item) {
                return true;
            }
        }
        return false;
    }
};

test TokenIterator {
    var it = TokenIterator{ .buffer = "Jest something", .delimiter = " ", .index = 0 };
    const first = it.next();
    const second = it.next();

    try std.testing.expectEqualStrings("Jest", first.?);
    try std.testing.expectEqualStrings("something", second.?);
}
