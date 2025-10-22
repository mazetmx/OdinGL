package main

import "core:os"
import "core:fmt"
import "core:strings"

read_file_to_cstring :: proc(filepath: string) -> (cstring, bool) {
    data, ok := os.read_entire_file(filepath, context.allocator)
    if !ok {
        fmt.printfln("Cannot read file: %s", filepath)
        return "", false
    }
    defer delete(data, context.allocator)

    cstr, err := strings.clone_to_cstring(string(data), context.allocator)
    if err != nil {
        fmt.printfln("Error while reading file: %v", err)
        return "", false
    }

    return cstr, true
}
