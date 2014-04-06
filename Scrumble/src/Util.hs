module Util
( (.||.)
, (.&&.)
, requireJsonBodyWith
) where

import Prelude 
import Data.Aeson
import Data.Text
import Yesod
import Network.HTTP.Types.Status (badRequest400)
import qualified Data.HashMap.Strict as HM

(.||.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.||.) p1 p2 a = p1 a || p2 a

(.&&.) :: (a -> Bool) -> (a -> Bool) -> a -> Bool
(.&&.) p1 p2 a = p1 a && p2 a

requireJsonBodyWith :: (FromJSON a, MonadHandler m) => [(Text, Value)] -> m a
requireJsonBodyWith additions = liftHandlerT $ do
  Object hmap <- requireJsonBody
  let raw = Object $ hmap `HM.union` HM.fromList additions
  case fromJSON raw of 
    Success a -> return a
    Error msg -> sendResponseStatus badRequest400 msg
