module Util where

import Prelude (Bool, (&&), (||))

(.||.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.||.) p1 p2 a = p1 a || p2 a

(.&&.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.&&.) p1 p2 a = p1 a && p2 a
