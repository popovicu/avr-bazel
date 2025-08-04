# avr-bazel

This is a small example for using Bazel to build an embedded C binary for an AVR chip.

**This repo is meant to accompany the article at TODO**

## Hermeticity

The rules are not fully hermetic and they assume that your GCC tools for AVR are at `/home/uros/build/avr/sysroot` (this is just how it was defined on my machine). This path is hardcoded for simplicity. Edit the file in `toolchain/BUILD` for your own paths.

## Running on emulator

```
run_avr -m atmega328p -f 16000000 bazel-bin/software/software
```

`run_avr` is from the `simavr` project that can be found [here](https://github.com/buserror/simavr). This is an awesome project. :)