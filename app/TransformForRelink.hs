import qualified Data.ByteString.Lazy as L
import System.Environment (getArgs)

import PointerTransformation

main :: IO ()
main = do
  args <- getArgs
  case args of
   [originalPath, relinkedPath] -> rewriteSerialized originalPath relinkedPath "serialized"
   _ -> error "Syntax: <originalPath> <relinkedPath>"

rewriteSerialized :: FilePath -> FilePath -> FilePath -> IO ()
rewriteSerialized originalPath relinkedPath serializedPath = do
  serialized <- L.readFile serializedPath
  transformed <- transform originalPath relinkedPath serialized
  L.writeFile (serializedPath++"_transformed") transformed
