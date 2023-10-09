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
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferResizeCallback);

    const vertices = [_]f32{
        -0.5, -0.5, 0.0, //Left
        0.5, -0.5, 0.0, //Right
        0.0, 0.5, 0.0, //Top
    };
    var VBO: c_uint = undefined;

    c.glGenBuffers(1, &VBO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(
        c.GL_ARRAY_BUFFER,
        vertices.len * @sizeOf(f32),
        &vertices,
        c.GL_STATIC_DRAW,
    );

    while (c.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glfwPollEvents();
        c.glfwSwapBuffers(window);
    }
}

fn processInput(window: ?*c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
}

fn framebufferResizeCallback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}
