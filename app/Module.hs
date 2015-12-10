module Module (serializedFunction, innerSerializedFunction) where

serializedFunction :: String -> String
serializedFunction = innerSerializedFunction

innerSerializedFunction :: String -> String
innerSerializedFunction = (++ "append1")
