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

parsePoker :: StoryId -> PokerValue -> Poker
parsePoker storyId (PokerValue modified content) = 
  Poker storyId modified $ decodeUtf8 $ toStrict $ encode content

getPokerR :: ProjectId -> SprintId -> StoryId -> Handler Value
getPokerR projectId _ storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  pokerEM <- runDB $ getBy $ UniquePokerStory storyId
  maybe (notFound)
        (return . toJSON . renderPoker)
        (pokerEM)

putPokerR :: ProjectId -> SprintId -> StoryId -> Handler ()
putPokerR projectId _ storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  val :: PokerValue <- requireJsonBody
  runDB $ do 
    deleteBy $ UniquePokerStory storyId
    _ <- insert $ parsePoker storyId val
    return ()