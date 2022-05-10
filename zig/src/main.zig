const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const drawFrame = @import("tracer.zig").drawFrame;

const WIN_W = 1200;
const WIN_H = 750;

fn draw(tex: *c.SDL_Texture, tex_w: u32, tex_h: u32) void {
    const stdout = std.io.getStdOut().writer();
    const start_timestamp = std.time.milliTimestamp();
    defer {
        const end_timestamp = std.time.milliTimestamp();
        const delta = end_timestamp - start_timestamp;
        stdout.print("[RAY] Delta {d:.2}s.\n", .{@intToFloat(f32, delta) / 1000.0}) catch std.log.err("STDOUT Error", .{});
    }

    var pitch: c_int = undefined;
    var pixels: [*]u8 = undefined;
    _ = c.SDL_LockTexture(
        tex,
        null,
        @ptrCast([*c]?*anyopaque, &pixels),
        &pitch,
    );
    defer c.SDL_UnlockTexture(tex);

    drawFrame(pixels, tex_w, tex_h);
}

pub fn main() !void {
    std.log.info("[RAY] Start", .{});
    defer std.log.info("[RAY] End", .{});

    // SDL init
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("SDL Err: %s", c.SDL_GetError());
        return error.SDLInitError;
    }
    defer c.SDL_Quit();

    // SDL window
    const window = c.SDL_CreateWindow(
        "Ray Tracer",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        WIN_W,
        WIN_H,
        c.SDL_WINDOW_SHOWN,
    );
    if (window == null) {
        c.SDL_Log("SDL Err: %s", c.SDL_GetError());
        return error.SDLWindowError;
    }
    defer c.SDL_DestroyWindow(window);

    // SDL renderer
    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED);
    if (renderer == null) {
        c.SDL_Log("SDL Err: %s", c.SDL_GetError());
        return error.SDLRendererError;
    }
    defer c.SDL_DestroyRenderer(renderer);

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);

    // SDL main texture
    const texture = c.SDL_CreateTexture(
        renderer,
        c.SDL_PIXELFORMAT_ARGB8888,
        c.SDL_TEXTUREACCESS_STREAMING,
        WIN_W,
        WIN_H,
    );
    if (texture == null) {
        c.SDL_Log("SDL Err: %s", c.SDL_GetError());
        return error.SDLTextureError;
    }
    defer c.SDL_DestroyTexture(texture);

    draw(texture orelse unreachable, WIN_W, WIN_H);
    //catch |err| {
    //std.log.err("[RAY] Draw error {0}", .{err});
    //};

    // Gameloop
    var quit = false;
    var event: c.SDL_Event = undefined;
    while (!quit) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYUP => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_q => {
                            quit = true;
                        },
                        c.SDLK_ESCAPE => {
                            quit = true;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, texture, null, null);
        c.SDL_RenderPresent(renderer);
    }
}
