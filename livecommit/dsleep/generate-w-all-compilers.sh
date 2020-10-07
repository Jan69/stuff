#!/bin/sh
#add more compilers and wrappers if you know of any! (must be x86 or x86_64 capable)
# gcc - gnu c compiler
# clang - LLVM C compiler
# diet - gcc wrapper for dietlibc
# musl - gcc wrapper for musl libc
# tcc - tiny c compiler
#       (see https://bellard.org/tcc/ and https://en.wikipedia.org/wiki/Tiny_C_Compiler,
#       slightly developed by community, not particularly maintained)
rm -r out/;for CC in tcc gcc clang diet musl;do CC=$CC ./generate.sh;done
