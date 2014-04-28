module Util
( (.||.)
, (.&&.)
, requireJsonBodyWith
, currentTimestamp
) where

import Prelude 
import Data.Aeson
import Data.Text
import Yesod
import Control.Applicative
import Data.Time.Clock.POSIX (getPOSIXTime)
import Network.HTTP.Types.Status (badRequest400)
import qualified Data.HashMap.Strict as HM

(.||.) :: (Applicative f) => f Bool -> f Bool -> f Bool
(.||.) = liftA2 (||)

(.&&.) :: (Applicative f) => f Bool -> f Bool -> f Bool
(.&&.) = liftA2 (&&)

requireJsonBodyWith :: (FromJSON a, MonadHandler m) => [(Text, Value)] -> m a
requireJsonBodyWith additions = liftHandlerT $ do
  Object hmap <- requireJsonBody
  let raw = Object $ hmap `HM.union` HM.fromList additions
  case fromJSON raw of 
    Success a -> return a
    Error msg -> sendResponseStatus badRequest400 msg

currentTimestamp :: Integral b => IO b
currentTimestamp = (round . (*1000)) `fmap` getPOSIXTime