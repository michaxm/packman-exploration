import qualified Data.ByteString.Lazy as BL

import Lib

main :: IO ()
main = do
  putStrLn "read - this would fail with the output of relink1, but should work with the transformed pointers"
  serialized <- BL.readFile "serialized_transformed"
  print serialized
  unserialized <- unwrapFromBinary serialized
  putStrLn $ unserialized "qwe"
