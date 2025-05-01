package main

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH  :: 800
HEIGHT :: 600
TITLE  :: "LearnOpenGL"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

vertex_shader_source: cstring = `
    #version 330 core
    layout (location = 0) in vec3 aPos;
    void main()
    {
        gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0f);
    }`

fragment_shader_source: cstring = `
    #version 330 core
    out vec4 FragColor;
    void main()
    {
        FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }`

main :: proc() {
    // GLFW Setup
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    if !bool(glfw.Init()) {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()

    window := glfw.CreateWindow(800, 600, "LearnOpenGL", nil, nil)
    defer glfw.DestroyWindow(window)

    if window == nil {
        fmt.eprintln("Failed to create GLFW window")
        return
    }

    glfw.MakeContextCurrent(window)

    glfw.SetFramebufferSizeCallback(window, frame_buffer_size_callback)

    // OpenGL Setup
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    // Vertex shader
    vertex_shader: u32 = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
    gl.CompileShader(vertex_shader)

    // Fragment shader
    fragment_shader: u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &fragment_shader_source, nil)
    gl.CompileShader(fragment_shader)

    // Link Shader
    shader_program: u32 = gl.CreateProgram()
    gl.AttachShader(shader_program, vertex_shader)
    gl.AttachShader(shader_program, fragment_shader)
    gl.LinkProgram(shader_program)
    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(fragment_shader)

    // Veretx data
    vertices: [9]f32 = {
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0,
    }

    VBO, VAO: u32
    gl.GenVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO)
    gl.BindVertexArray(VAO)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO) // bind the VBO to the ARRAY_BUFFER buffer type
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices[0], gl.STATIC_DRAW) // copies the data in the vertices array to the array buffer in the gpu

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)

    // Main Loop
    for !glfw.WindowShouldClose(window) {
        // Input
        process_input(window)

        // Render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shader_program)
        gl.BindVertexArray(VAO)
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

        // Check event and swap the buffers
        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}

process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}

// GLFW will call this automatically when the window size changes
frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}
