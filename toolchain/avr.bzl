load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "feature", "tool_path", "flag_group", "flag_set")

def _impl(ctx):
    toolchain_tools = ["gcc", "ld", "ar", "cpp", "gcov", "nm", "objdump", "strip"]
    # TODO: do not hardcode the path
    tool_paths = [tool_path(name = tool, path = "{}/bin/avr-{}".format(ctx.attr.system_avr_gcc_path, tool)) for tool in toolchain_tools]

    ASSEMBLE_ACTIONS = [
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
    ]
    
    COMPILE_ACTIONS = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.c_compile
    ]
    
    ASSEMBLE_AND_COMPILE_ACTIONS = ASSEMBLE_ACTIONS + COMPILE_ACTIONS

    compile_flags = feature(
        name = "compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ASSEMBLE_AND_COMPILE_ACTIONS,
                flag_groups = [
                    flag_group(
                        flags = ["-mmcu=" + ctx.attr.mmcu, "-DF_CPU=" + ctx.attr.f_cpu, "-Os"],
                    ),
                ],
            )
        ],
    )

    LINK_ACTIONS = [
        ACTION_NAMES.cpp_link_executable,
    ]
    
    link = feature(
        name = "link",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = LINK_ACTIONS,
                flag_groups = [
                    flag_group(
                        flags = ["-mmcu=" + ctx.attr.mmcu, "-static"],
                    ),
                ],
            )
        ],
    )

    no_build_id = feature(
        name = "no_build_id",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = LINK_ACTIONS,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,--build-id=none"],
                    ),
                ],
            )
        ],
    )
    
    features = [compile_flags, link, no_build_id]
    
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "local",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "avr",
        target_libc = "unknown",
        compiler = "gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = [
            "{}/avr/include/".format(ctx.attr.system_avr_gcc_path),
            "{}/lib/gcc/avr/14.2.0/include/".format(ctx.attr.system_avr_gcc_path),
        ],
        features = features,
    )

avr_toolchain = rule(
    implementation = _impl,
    attrs = {
        "mmcu": attr.string(mandatory = True),
        "system_avr_gcc_path": attr.string(mandatory = True),
        "f_cpu": attr.string(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)

def toolchain_setup(name, *, mmcu, system_path, f_cpu, target_constraints):
    avr_toolchain(
        name = "%s_config" % name,
        mmcu = mmcu,
        f_cpu = f_cpu,
        system_avr_gcc_path = system_path,
    )

    native.filegroup(name = "%s_empty" % name)

    native.cc_toolchain(
        name = "%s_toolchain" % name,
        toolchain_identifier = "local",
        toolchain_config = ":%s_config" % name,
        all_files = ":%s_empty" % name,
        compiler_files = ":%s_empty" % name,
        dwp_files = ":%s_empty" % name,
        linker_files = ":%s_empty" % name,
        objcopy_files = ":%s_empty" % name,
        strip_files = ":%s_empty" % name,
        supports_param_files = False,
    )

    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = target_constraints,
        toolchain = ":%s_toolchain" % name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)