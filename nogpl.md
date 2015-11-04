# nogpl
### replacements for GPL implementations of programs and libraries

# system core
## libc
- musl - A lightweight standard C library - MIT

## init
- nosh - suite of utilities for managing daemons/terminals - MIT/ISC/BSD-2
    - can use systemd units
- Beginning - simple BSD-style rc.d init - ISC
- - perp - Persistent process supervisor, service management framework - BSD-2
- s6 - Process supervision toolbox - ISC
- daemontools - DJB's famous collection of tools for managing services - Public domain
    - daemontools-encore - MIT
- runit - init scheme with service supervision - BSD-3

## coreutils
- toybox - Implementation of common Linux command line utilities - BSD/Public domain
    - likely the most promising implementation. keep an eye on it.
    - includes all coreutils (bar a few GNU weird ones)

## tar
- libarchive - includes feature-complete versions of tar and cpio - BSD-2
    - did you know you can use it to replace unzip? `tar xvf file.zip`!

## awk
- lok - Linux port of OpenBSD awk - ISC/some sort of BSD

# various
## man
- mandoc - Alternative to groff, man-db - ISC

# build tools
## compilers
- clang/clang++ - LLVM-based C, C++, Obj-C++ compiler - UoI/NCSA

## debuggers
- lldb - LLVM project debugger - UoI/NCSA

## m4
- OpenBSD m4 - implementation of m4 with some GNU extensions - BSD-2/ISC

## misc.
- pkgconf - Drop-in replacement for pkg-config. - ISC
-
