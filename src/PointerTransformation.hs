{-# LANGUAGE ScopedTypeVariables #-}
module PointerTransformation where

import Data.Bits (shiftR)
import Data.List.Split (splitOn)
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Word (Word8, Word64)
import System.Exit (ExitCode(..))
import System.Process (readProcessWithExitCode)
import qualified Data.ByteString.Lazy as L

transform :: FilePath -> FilePath -> L.ByteString -> IO L.ByteString
transform originalBinaryPath newBinaryPath serialized = do
  (ExitSuccess, origNm, []) <- readProcessWithExitCode "nm" [originalBinaryPath] ""
  (ExitSuccess, newNm, []) <- readProcessWithExitCode "nm" [newBinaryPath] ""
  return $ replaceHitsAfter wordOffsetConst origNm newNm serialized

replaceHitsAfter :: Int -> String -> String -> L.ByteString -> L.ByteString
replaceHitsAfter offset origNm newNm = applyMappingAfter offset $ buildMapping origNm newNm

{-
 Mapping:

 1) get exported symbols from nm, get the main closure address
 2) for origin build a map for each symbol: serialized address -> symbol name
    where serialized address = symbol adress - main closure address +1
 3) for new binary build a map for each symbol : symbol name -> serialized address (for new)
 4) left join maps over symbol name

 optimizing lookup: serialized address will be 8 bytes (64Bit arch)
 +1: probably Marker (PLC)?
 note in hindsight: doing the mapping on the fly while traversing the serialized thunk could be faster in general,
   since the the thunk should be considerably smaller than the symbol map (if it consists primarily of pointer and not a lot of serialized data)
-}
wordOffsetConst :: Int
wordOffsetConst = 8 -- serialization header word length (is it really constant?)
type PointerAddr = Word64 -- 8 Bytes
type Mapping = Map PointerAddr PointerAddr

buildMapping :: String -> String -> Mapping
buildMapping origNm newNm = joinMaps transformedOrigMapping transformedNewMapping
  where
    origMapping = buildLineMap 0 2 " " origNm
    newMapping = buildLineMap 2 0 " " newNm
    buildLineMap :: Int -> Int -> String -> String -> Map String String
    buildLineMap keyIndex valueIndex delim input = foldr appendToLineMap Map.empty (lines input)
      where
        appendToLineMap :: String -> Map String String -> Map String String
        appendToLineMap line map' =
          let cells = (filter (not . null) . (splitOn delim)) line in
           if length cells <= max keyIndex valueIndex
           then map'
           else Map.insert (cells !! keyIndex) (cells !! valueIndex) map'
    origOffset = maybe (error "no main offset found for orig binary") id $ findKeyForValue mainSymbol origMapping
      where findKeyForValue v m = Map.foldrWithKey (\k' v' r' -> if v == v' then Just k' else r') Nothing m
    newOffset = maybe (error "no main offset found for new binary") id $ Map.lookup mainSymbol newMapping
    mainSymbol = "ZCMain_main_info"
    transformedOrigMapping = Map.mapKeys (toSerializedAddress origOffset) origMapping
    transformedNewMapping = Map.map (toSerializedAddress newOffset) newMapping

toSerializedAddress :: String -> String -> PointerAddr
toSerializedAddress mainOffset = (+1) . (flip (-) mainOffsetHex) . readHexValue
  where
    mainOffsetHex = readHexValue mainOffset
    readHexValue :: String -> PointerAddr
    readHexValue = read . ("0x" ++)

-- shouldn't this already be out there?
joinMaps :: forall a b c . (Ord a, Ord b) => Map a b -> Map b c -> Map a c
joinMaps map1 map2 = Map.foldrWithKey mapEntry Map.empty map1
  where
    mapEntry :: (Ord a, Ord b) => a -> b -> Map a c -> Map a c
    mapEntry key1 key2 resultMap =
      maybe resultMap (\value2 -> Map.insert key1 value2 resultMap) (Map.lookup key2 map2)

applyMappingAfter :: Int -> Mapping -> L.ByteString -> L.ByteString
applyMappingAfter wordOffset mapping serialized = concatWords $ (take wordOffset serializedWords) ++ (map applyMapping' $ drop wordOffset serializedWords)
  where
    concatWords :: [PointerAddr] -> L.ByteString
    concatWords = L.pack . unpack64
    serializedWords :: [PointerAddr]
    serializedWords = {-chunksOf wordLength-} pack64 $ L.unpack serialized
    applyMapping' :: PointerAddr -> PointerAddr
    applyMapping' serializedPointer = maybe serializedPointer id $ Map.lookup serializedPointer mapping

-- | Converts a list of 64-bit words into a list of 8-bit words.
-- borrowed from adhoc-network
unpack64 :: [Word64] -> [Word8]
unpack64 = concatMap (\x -> map (fromIntegral.(shiftR x)) [56,48..0])

-- | Packs a stream of 8-bit Words into a stream of 64-bit Words.
-- borrowed from adhoc-network
pack64 :: [Word8] -> [Word64]
pack64 []  = []
pack64 lst = let
        (now,later) = splitAt 8 lst
        val = fromOctets (256::Int) now
        in val:pack64 later

-- | Take a list of octets (a number expressed in base n) and convert it
--   to a number.
-- borrowed from Crypto
fromOctets :: (Integral a, Integral b) => a -> [Word8] -> b
fromOctets n x = 
   fromIntegral $ 
   sum $ 
   zipWith (*) (powersOf n) (reverse (map fromIntegral x))
   where
     powersOf n' = 1 : (map (*n') (powersOf n'))
