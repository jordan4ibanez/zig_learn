const std = @import("std");
const stbi = @import("zstbi");

pub const HeightMap = struct {
    width: u32,
    height: u32,
    
    data: [][]f32,
};
