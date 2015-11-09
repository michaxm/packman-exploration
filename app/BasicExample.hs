import Data.Char (isLower)
import GHC.Packing

import Lib

main = do

  putStrLn "testing (un-)wrapping in Serializable:"
  blob <- trySerialize f 
  print blob
  deserialize blob >>= apply

  putStrLn "testing complete binary serialization:"
  bs <- wrapToBinary f
  print bs
  unwrapFromBinary bs >>= apply

  putStrLn "I did not really bother to make serialization with read/show work, deserialization will fail:"
  str <- wrapToString f
  print str
  unwrapFromString str >>= apply
  where
    -- serialization and deserialization both need monomorphism, tried an example with an inferred function type here
    f = isLower
    apply f = putStrLn $ "applying: " ++ (toStr $ map f "AaA") ++ "\n\n"
      where
        -- ... show needs monomorphism, too ..
        toStr :: [Bool] -> String
        toStr = show
