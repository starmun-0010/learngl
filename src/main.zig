const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});
pub fn main() void {
    std.debug.print("Learni\n", .{});
    const success = c.glfwInit();
    if (success == 0) {
        std.debug.panic("Failed to init GLFW", .{});
    }
    var window = c.glfwCreateWindow(1920, 1080, "Learn OpenGL", null, null);

    if (window == null) {
        std.debug.panic("Failed to create GLFW window", .{});
    }

    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@as(c.GLADloadproc, @ptrCast(&c.glfwGetProcAddress))) == 0) {
        std.debug.panic("Failed to initialise GLAD\n", .{});
    }
}
