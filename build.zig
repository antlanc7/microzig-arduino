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

    const tty = b.option(
        []const u8,
        "tty",
        "Specify the port to which the Arduino is connected (defaults to COM3)",
    ) orelse "COM3";

    const bin_path = b.getInstallPath(exe.inner.install_step.?.dest_dir, exe.inner.out_filename);

    const flash_command = blk: {
        var tmp = std.ArrayList(u8).init(b.allocator);
        try tmp.appendSlice("-Uflash:w:");
        try tmp.appendSlice(bin_path);
        try tmp.appendSlice(":e");
        break :blk tmp.toOwnedSlice();
    };

    const upload = b.step("upload", "Upload the code to an Arduino device using avrdude");
    const avrdude = b.addSystemCommand(&.{
        "avrdude",
        "-CC:\\Program Files (x86)\\Arduino\\hardware\\tools\\avr\\etc\\avrdude.conf",
        "-carduino",
        "-patmega328p",
        "-D",
        "-P",
        tty,
        flash_command,
    });
    upload.dependOn(&avrdude.step);
    avrdude.step.dependOn(&exe.inner.install_step.?.step);
}
