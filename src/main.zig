const microzig = @import("microzig");

// `microzig.chip.registers`: access to register definitions
// `microzig.config`: comptime access to configuration
//                  - chip_name: name of the chip
//                  - has_board: true if board is configured
//                  - board_name: name of the board is has_board is true
//                  - cpu_name: name of the CPU

fn delayMilliseconds(milliseconds: u32) void {
    // Each iteration is 256 * 4 cycles
    //   + a few cycles for u32 outer loop / interrupts....
    var i: u32 = milliseconds * (16_000_000 / (1000 * (256 * 4) + 42));
    while (i > 0) : (i -= 1) {
        var c: u8 = 255;
        asm volatile (
            \\1:
            \\    dec %[c]
            \\    nop
            \\    brne 1b
            :
            : [c] "r" (c),
        );
    }
}

const led_pin = microzig.Pin("D13");
const led = microzig.Gpio(led_pin, .{ .mode = .output, .initial_state = .low });

pub fn main() !void {
    led.init();
    // your program here
    while (true) {
        led.toggle();
        delayMilliseconds(1000);
    }
}
