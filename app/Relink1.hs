import qualified Data.ByteString.Lazy as BL

import Lib
import Module

main :: IO ()
main = do
  putStrLn "serialize"
  serialized <- wrapToBinary f
  print serialized
  BL.writeFile "serialized" serialized
