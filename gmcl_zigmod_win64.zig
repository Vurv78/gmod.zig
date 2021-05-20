const std = @import("std");
const fmt = std.fmt;

const builtin = @import("builtin");

usingnamespace std.os.windows;

const LuaState = ?*c_void;
const VoidPtr = ?*c_void;

const CharBuf = [*c]const u8;

const LUA_MULTRET = -1;

extern "user32" fn MessageBoxA(hWnd: ?HANDLE, desc: CharBuf, title: CharBuf, uType: c_uint) c_int;

extern "kernel32" fn LoadLibraryA(name: CharBuf) ?*c_void;
extern "kernel32" fn GetProcAddress(mod: ?*c_void, nax: CharBuf) ?*c_void;
extern "kernel32" fn GetModuleFileNameA(mod: LuaState, name: [*c]u8, len: c_int) c_int;
extern "kernel32" fn ExitProcess(code: c_int) noreturn;

pub const loadstring_t = ?fn (LuaState, CharBuf) callconv(.C) c_int;
pub const pcall_t = ?fn (LuaState, c_int, c_int, c_int) callconv(.C) c_int;

pub const msg_t = ?fn (CharBuf) callconv(.C) void;

pub export fn gmod13_open(state: LuaState) BOOL {
    // Spawns a message box that will halt the game.

    var lua_shared: VoidPtr = LoadLibraryA("lua_shared");
    if (lua_shared == null) {
        _ = MessageBoxA(null, "Failed to get lua_shared", "Error", 0);
        ExitProcess(1);
    }

    var tier0: VoidPtr = LoadLibraryA("tier0");
    if (tier0 == null) {
        _ = MessageBoxA(null, "Failed to get tier0", "Error", 0);
        ExitProcess(1);
    }

    // tier0
    var msg: msg_t = @ptrCast(msg_t, GetProcAddress(tier0, "Msg"));

    // lua_shared
    var luaL_loadstring: loadstring_t = @ptrCast(loadstring_t, GetProcAddress(lua_shared, "luaL_loadstring"));
    var lua_pcall: pcall_t = @ptrCast(pcall_t, GetProcAddress(lua_shared, "lua_pcall"));

    msg.?("Hello world!\n");

    return 1;
}

pub export fn gmod13_close(state: LuaState) BOOL {
    return 1;
}