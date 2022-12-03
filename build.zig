const std = @import("std");
const microzig = @import("microzig/src/main.zig");

pub fn build(b: *std.build.Builder) !void {
    const backing = .{
        .board = microzig.boards.arduino_uno,
    };

    var exe = microzig.addEmbeddedExecutable(
        b,
        "main",
        "src/main.zig",
        backing,
        .{
            // optional slice of packages that can be imported into your app:
            // .packages = &my_packages,
        },
    );
    exe.setBuildMode(.ReleaseSmall);
    exe.install();
}
