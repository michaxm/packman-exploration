import qualified Data.ByteString.Lazy as BL

import Lib
import Module

main :: IO ()
main = do
  putStrLn "read - this will fail with the output of relink1"
  serialized <- BL.readFile "serialized"
  print serialized
  unserialized <- unwrapFromBinary serialized
  putStrLn $ unserialized "qwe"
  
