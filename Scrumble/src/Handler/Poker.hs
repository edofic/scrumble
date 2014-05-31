module Handler.Poker 
( getPokerR
, putPokerR
) where

import Import
import GHC.Generics
import Data.Aeson (decodeStrict, encode)
import Data.ByteString.Lazy (toStrict)
import Data.Text.Encoding (encodeUtf8, decodeUtf8)
import qualified Authorization as Auth

data PokerValue = PokerValue { lastModified :: Int64
                             , content :: Value 
                             } deriving (Eq, Show, Generic)

instance FromJSON PokerValue 
instance ToJSON PokerValue 

renderPoker :: Entity Poker -> PokerValue
renderPoker (Entity _ (Poker _ modified txt)) = 
  PokerValue modified val where
    Just val = decodeStrict $ encodeUtf8 txt

parsePoker :: ProjectId -> PokerValue -> Poker
parsePoker projectId (PokerValue modified content) = 
  Poker projectId modified $ decodeUtf8 $ toStrict $ encode content

getPokerR :: ProjectId -> Handler Value
getPokerR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  pokerEM <- runDB $ getBy $ UniquePokerProject projectId
  maybe (notFound)
        (return . toJSON . renderPoker)
        (pokerEM)

putPokerR :: ProjectId -> Handler ()
putPokerR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  val :: PokerValue <- requireJsonBody
  runDB $ do 
    deleteBy $ UniquePokerProject projectId
    _ <- insert $ parsePoker projectId val
    return ()