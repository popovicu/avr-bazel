constraint_value(
    name = "avr_atmega",
    constraint_setting = "@platforms//cpu",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "bare_metal",
    constraint_setting = "@platforms//os",
    visibility = ["//visibility:public"],
)

platform(
    name = "avr_atmega_bare_metal",
    constraint_values = [
        ":bare_metal",
        ":avr_atmega",
    ],
)