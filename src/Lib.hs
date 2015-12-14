module Lib where

import Data.Binary
import qualified Data.ByteString.Lazy as L
import Data.Typeable (Typeable)
import GHC.Packing

wrapToBinary :: (Typeable a) => a -> IO L.ByteString
wrapToBinary a = trySerialize a >>= return . encode
  
unwrapFromBinary :: (Typeable a) => L.ByteString -> IO a
unwrapFromBinary = deserialize . decode

wrapToString :: (Typeable a) => a -> IO String
wrapToString a = trySerialize a >>= return . show

unwrapFromString :: (Typeable a) => String -> IO a
unwrapFromString = deserialize . read
