module Main where

import Data.Binary
import Data.Char (isLower)
import qualified Data.ByteString.Lazy as L
import Data.Typeable (Typeable)
import GHC.Packing


main = do

  putStrLn "testing (un-)wrapping in Serializable:"
  blob <- trySerialize f 
  print blob
  deserialize blob >>= apply

  putStrLn "testing complete binary serialization:"
  bs <- wrapToBinary f
  print bs
  unwrapFromBinary bs >>= apply

  where
    -- serialization and deserialization both need monomorphism, tried an example with an inferred function type here
    f = isLower
    apply f = putStrLn $ "applying: " ++ (toStr $ map f "AaA") ++ "\n\n"
      where
        -- ... show needs monomorphism, too ..
        toStr :: [Bool] -> String
        toStr = show

wrapToBinary :: (Typeable a) => a -> IO L.ByteString
wrapToBinary a = trySerialize a >>= return . encode
  
unwrapFromBinary :: (Typeable a) => L.ByteString -> IO a
unwrapFromBinary = deserialize . decode

