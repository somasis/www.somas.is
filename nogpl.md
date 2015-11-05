# nogpl
### replacements for GPL implementations of programs and libraries

## init
- nosh - suite of utilities for managing daemons/terminals - MIT/ISC/BSD-2
    - can use systemd units!
- Beginning - simple BSD-style rc.d init - ISC
    - heavily inspired from arch linux initscripts
- perp - Persistent process supervisor, service management framework - BSD-2
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

## sed
- toybox sed - BSD/Public domain

## man
- mandoc - Alternative to groff, man-db - ISC

## udev
- vdev - very cool cross-platform device-file manager - ISC (dual-licensed with GPLv3+)
    - some Linux-specific programs are derived from udev source, and are GPLv2

# libraries
## libc
- musl - A lightweight standard C library - MIT

## readline
- libedit - line editor library with history, tokenization, unicode - BSD-3
    - with a few symlinks it is source-code compatible with readline

# toolchain/development
## compilers
- clang/clang++ - LLVM-based C, C++, Obj-C++ compiler - UoI/NCSA

## m4
- OpenBSD m4 - implementation of m4 with some GNU extensions - BSD-2/ISC
- Quasar m4 - drop-in replacement for GNU m4, forked from FreeBSD 9.1 - BSD-2

## debuggers
- lldb - LLVM project debugger - UoI/NCSA

## libtool
- don't use it! - Public domain

## pkg-config
- pkgconf - Drop-in replacement for pkg-config. - ISC

[musl]:         http://www.musl-libc.org/
[nosh]:         http://homepage.ntlworld.com/jonathan.deboynepollard/Softwares/nosh.html
[beginning]:    https://github.com/Somasis/beginning
[perp]:         http://b0llix.net/perp/
[s6]:           http://skarnet.org/software/s6/
[daemontools]:  http://cr.yp.to/daemontools.html
[runit]:        http://smarden.org/runit/
[toybox]:       http://landley.net/toybox/
[libarchive]:   http://libarchive.org/
[lok]:          https://github.com/dimkr/lok
[mandoc]:       http://mdocml.bsd.lv/
[clang]:        http://clang.llvm.org/
[lldb]:         http://lldb.llvm.org/
[openbsd m4]:   http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/usr.bin/m4/
[quasar m4]:    http://haddonthethird.net/m4/
[pkgconf]:      https://github.com/pkgconf/pkgconf
