package main

import "core:fmt"
import gl "vendor:OpenGL"

init_shader :: proc(vertex_shader_path: string, fragment_shader_path: string) -> bool {
    vertex_shader_source, vert_ok := read_file_to_cstring(vertex_shader_path)
    if !vert_ok {
        fmt.printfln("Cannot load vertex shader: %s", vertex_shader_path)
        return false
    }

    frag_shader_source, frag_ok := read_file_to_cstring(fragment_shader_path)
    if !frag_ok {
        fmt.printfln("Cannot load fragment shader: %s", fragment_shader_path)
        return false
    }

    // Vertex shader
    vertex_shader: u32 = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
    gl.CompileShader(vertex_shader)
    // check shader validity
    success: i32
    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        fmt.printfln("Error while compiling vertex shader")
        return false
    }

    // Fragment shader
    fragment_shader: u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &frag_shader_source, nil)
    gl.CompileShader(fragment_shader)
    // check shader validity
    gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        fmt.printfln("Error while compiling fragment shader")
        return false
    }

    // Link shaders
    shader_program = gl.CreateProgram()
    gl.AttachShader(shader_program, vertex_shader)
    gl.AttachShader(shader_program, fragment_shader)
    gl.LinkProgram(shader_program)
    // check program validity
    gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
    if success == 0 {
        fmt.printfln("Error while linking shaders")
        return false
    }
    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(fragment_shader)

    return true
}
