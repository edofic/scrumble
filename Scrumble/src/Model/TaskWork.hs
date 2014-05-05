module Model.TaskWork where

import Prelude
import Yesod
import Data.Int (Int64)
import Data.Maybe (fromJust)
import Data.ByteString.Lazy.Char8 (pack, unpack)
import Data.Aeson (encode, decode)
import GHC.Generics
import Text.Read

data TaskWork = TaskWork { time      :: Int64
                         , done      :: Double
                         , remaining :: Double
                         } deriving (Eq, Generic)

instance ToJSON TaskWork
instance FromJSON TaskWork

instance Show TaskWork where
  show = unpack . encode

instance Read TaskWork where
  readsPrec _ = f . lex where
    f [(input, str)] = [(fromJust $ decode $ pack input, str)]

derivePersistField "TaskWork"
