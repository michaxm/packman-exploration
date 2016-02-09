import qualified Data.ByteString.Lazy as BL

import Lib

main :: IO ()
main = do
  putStrLn "serialize"
  serialized <- wrapToBinary (++ "append1")
  print serialized
  BL.writeFile "serialized" serialized
