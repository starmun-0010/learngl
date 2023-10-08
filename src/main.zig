const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
});
pub fn main() void {
    std.debug.print("Learni\n", .{});
    if (c.gladLoadGLLoader(@as(c.GLADloadproc, @ptrCast(&0))) == 0) {
        std.debug.panic("Failed to initialise GLAD\n", .{});
    }
}
