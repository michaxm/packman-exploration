#!/bin/bash -e

rm -rf build/*
mkdir -p build

echo prebuilding
/usr/local/bin/ghc\
 -no-link\
 -outputdir build\
 app/BasicExample.hs\
 -package-db ~/.stack/snapshots/x86_64-linux/lts-2.22/7.8.4/pkgdb/\
 -package-db ~/projects/packman-exploration/packman/.stack-work/install/x86_64-linux/lts-2.22/7.8.4/pkgdb/\
 -package-id packman-0.2-ae45cb68343e3c66c103e40255df6c08\

echo

echo linking with .a
rm -f build/manually-linked
/usr/local/bin/ghc\
 -o build/manually-linked-static\
 -outputdir build\
 build/Main.o\
 -static\
 /usr/local/lib/ghc-7.8.4/rts-1.0/libHSrts.a\
 packman/.stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/libHSpackman-0.2.a\
 /usr/local/lib/ghc-7.8.4/binary-0.7.1.0/libHSbinary-0.7.1.0.a\
 /usr/local/lib/ghc-7.8.4/bytestring-0.10.4.0/libHSbytestring-0.10.4.0.a\
 /usr/local/lib/ghc-7.8.4/containers-0.5.5.1/libHScontainers-0.5.5.1.a\
 /usr/local/lib/ghc-7.8.4/deepseq-1.3.0.2/libHSdeepseq-1.3.0.2.a\
 /usr/local/lib/ghc-7.8.4/array-0.5.0.0/libHSarray-0.5.0.0.a\
 /usr/local/lib/ghc-7.8.4/base-4.7.0.2/libHSbase-4.7.0.2.a\

build/manually-linked-static


echo linking with .so
/usr/local/bin/ghc\
 -o build/manually-linked-shared\
 -outputdir build\
 build/Main.o\
 /usr/local/lib/ghc-7.8.4/rts-1.0/libHSrts-ghc7.8.4.so\
 packman/.stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/libHSpackman-0.2-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/binary-0.7.1.0/libHSbinary-0.7.1.0-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/bytestring-0.10.4.0/libHSbytestring-0.10.4.0-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/containers-0.5.5.1/libHScontainers-0.5.5.1-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/deepseq-1.3.0.2/libHSdeepseq-1.3.0.2-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/array-0.5.0.0/libHSarray-0.5.0.0-ghc7.8.4.so\
 /usr/local/lib/ghc-7.8.4/base-4.7.0.2/libHSbase-4.7.0.2-ghc7.8.4.so\

build/manually-linked-shared
echo

