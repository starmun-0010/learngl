const std = @import("std");
const math = std.math;
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const SCR_WIDTH: u32 = 1920;
const SCR_HEIGHT: u32 = 1080;
const vertex_shader_source: [:0]const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\layout (location = 1) in vec3 aColor;
    \\out vec3 inputColor;
    \\void main()
    \\{
    \\  gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\  inputColor = aColor;
    \\};
;
const fragment_shader_source: [:0]const u8 =
    \\#version 330 core
    \\in vec3 inputColor;
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\  FragColor = vec4(inputColor, 1.0);
    \\}
;
pub fn main() void {

    //GLFW Setup

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

    //Rendering Setup
    const vertex_shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(
        vertex_shader,
        1,
        &vertex_shader_source.ptr,
        null,
    );
    c.glCompileShader(vertex_shader);

    var success: c_int = undefined;
    var infoLog: [512]u8 = undefined;
    c.glGetShaderiv(vertex_shader, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        c.glGetShaderInfoLog(vertex_shader, infoLog.len, null, &infoLog);
        std.debug.panic("ERROR::VERTEX::SHADER::COMPILATION_FAILED\n{s}\n", .{infoLog});
    }

    const fragment_shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(
        fragment_shader,
        1,
        &fragment_shader_source.ptr,
        null,
    );
    c.glCompileShader(fragment_shader);

    c.glGetShaderiv(fragment_shader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        c.glGetShaderInfoLog(
            fragment_shader,
            infoLog.len,
            null,
            &infoLog,
        );
        std.debug.panic("ERROR::VERTEX::FRAGMENT::COMPILATION_FAILED\n{s}\n", .{infoLog});
    }
    const shaderProgram = c.glCreateProgram();
    c.glAttachShader(shaderProgram, vertex_shader);
    c.glAttachShader(shaderProgram, fragment_shader);
    c.glLinkProgram(shaderProgram);

    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        c.glGetProgramInfoLog(shaderProgram, infoLog.len, null, &infoLog);
        std.debug.panic("ERROR::SHADER::PROGRAM::LINKING_FAILED\n{s}\n", .{infoLog});
    }
    c.glUseProgram(shaderProgram);

    const inputVertexColorLocation = c.glGetUniformLocation(shaderProgram, "inputColor");
    c.glUniform4f(inputVertexColorLocation, 0.0, 1.0, 0.0, 1.0);
    c.glDeleteShader(vertex_shader);
    c.glDeleteShader(fragment_shader);

    const vertices = [_]f32{
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, //Left
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, //Right
        0.5, 0.5, 0.0, 0.0, 0.0, 1.0, //Top Right
        -0.5, 0.5, 0.0, 1.0, 0.0, 1.0, //Top Left
    };
    const indices = [_]u32{
        0, 1, 2, //first,
        0, 3, 2, //2nd
    };
    var VAO: c_uint = undefined;
    var VBO: c_uint = undefined;
    var EBO: c_uint = undefined;

    c.glGenVertexArrays(1, &VAO);
    c.glBindVertexArray(VAO);

    c.glGenBuffers(1, &VBO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(
        c.GL_ARRAY_BUFFER,
        vertices.len * @sizeOf(f32),
        &vertices,
        c.GL_STATIC_DRAW,
    );
    c.glGenBuffers(1, &EBO);
    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, EBO);
    c.glBufferData(
        c.GL_ELEMENT_ARRAY_BUFFER,
        indices.len * @sizeOf(u32),
        &indices,
        c.GL_STATIC_DRAW,
    );

    c.glVertexAttribPointer(
        0,
        3,
        c.GL_FLOAT,
        c.GL_FALSE,
        6 * @sizeOf(f32),
        null,
    );
    c.glVertexAttribPointer(
        1,
        3,
        c.GL_FLOAT,
        c.GL_FALSE,
        6 * @sizeOf(f32),
        @ptrFromInt(3 * @sizeOf(f32)),
    );
    c.glEnableVertexAttribArray(0);
    c.glEnableVertexAttribArray(1);

    //c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
    while (c.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        const time = c.glfwGetTime();
        const greenValue: f32 = @floatCast(@abs(math.sin(time / 2.0)) + 0.1);

        c.glUniform4f(inputVertexColorLocation, 0.0, greenValue, 0.0, 1.0);

        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
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
