package main

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH  :: 800
HEIGHT :: 600
TITLE  :: "LearnOpenGL"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

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

    // Main Loop
    for !glfw.WindowShouldClose(window) {
        // Input
        process_input(window)

        // Render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

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
