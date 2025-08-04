load(":avr.bzl", "toolchain_setup")

toolchain_setup(
    name = "avr_atmega",
    mmcu = "atmega328p",
    target_constraints = [
        "//platform:bare_metal",
        "//platform:avr_atmega",
    ],
    system_path = "/home/uros/build/avr/sysroot",
    f_cpu = "16000000UL",
)