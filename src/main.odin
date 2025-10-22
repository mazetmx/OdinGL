package main

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH  :: 800
HEIGHT :: 600
TITLE  :: "LearnOpenGL"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

shader_program: u32

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

    // Shaders setup
    if !init_shader("./shaders/shader.vs", "./shaders/shader.fs") {
        glfw.Terminate()
        return
    }

    // Veretx data
    vertices: []f32 = {
        // positions      // colors
         0.5, -0.5, 0.0,  1.0, 0.0, 0.0, // bottom right
        -0.5, -0.5, 0.0,  0.0, 1.0, 0.0, // bottom left
         0.0,  0.5, 0.0,  0.0, 0.0, 1.0, // top
    }

    VBO, VAO: u32
    gl.GenVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO)

    gl.BindVertexArray(VAO)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO) // bind the VBO to the ARRAY_BUFFER buffer type
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), raw_data(vertices), gl.STATIC_DRAW) // copies the data in the vertices array to the array buffer in the gpu

    // position attribute
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), cast(uintptr)0)
    gl.EnableVertexAttribArray(0)
    // color attribute
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), cast(uintptr)(3 * size_of(f32)))
    gl.EnableVertexAttribArray(1)

    gl.UseProgram(shader_program)

    defer gl.DeleteVertexArrays(1, &VAO)
    defer gl.DeleteBuffers(1, &VBO)
    defer gl.DeleteProgram(shader_program)

    // Enable wireframe mode
    /* gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE) */

    // Main Loop
    for !glfw.WindowShouldClose(window) {
        // Input
        process_input(window)

        // Render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

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
