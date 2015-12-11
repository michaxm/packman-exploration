#!/bin/bash
rm .stack-work/install/x86_64-linux/lts-2.22/7.8.4/bin/relink*
stack build
stack exec relink1
stack exec transform-for-relink .stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/relink1/relink1 .stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/relink2/relink2
stack exec relink2
