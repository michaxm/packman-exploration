#!/bin/bash -e
stack build
stack exec no-top-level1
echo this can only fail horribly since the target code is not present in the target binary
#stack exec transform-for-relink .stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/no-top-level1/no-top-level1 .stack-work/dist/x86_64-linux/Cabal-1.18.1.5/build/no-top-level2/no-top-level2
#cp serialized serialized_transformed
echo running second program
stack exec relink2
