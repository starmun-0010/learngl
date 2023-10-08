const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() void {
    const SCR_WIDTH: u32 = 1920;
    const SCR_HEIGHT: u32 = 1080;

    const glfw_init_result = c.glfwInit();
    if (glfw_init_result == 0) {
        std.debug.panic("Failed to initialize GLFW", .{});
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(
        c.GLFW_OPENGL_PROFILE,
        c.GLFW_OPENGL_CORE_PROFILE,
    );
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);

    const window = c.glfwCreateWindow(
        SCR_WIDTH,
        SCR_HEIGHT,
        "Learn OpenGL",
        null,
        null,
    );
    if (window == null) {
        std.debug.panic("Failed to create GLFW window", .{});
    }
    c.glfwMakeContextCurrent(window);

    const glad_load_result = c.gladLoadGLLoader(@as(
        c.GLADloadproc,
        @ptrCast(&c.glfwGetProcAddress),
    ));
    if (glad_load_result == 0) {
        std.debug.panic("Failed to load GLAD.", .{});
    }
}
