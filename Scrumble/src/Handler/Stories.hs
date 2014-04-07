module Handler.Stories (getStoriesR, postStoriesR) where

import Import
import Control.Monad (when)
import Network.HTTP.Types.Status (badRequest400)

getStoriesR :: ProjectId -> Handler Value
getStoriesR projectId = do
  --TODO: assert project existance and user role on the project
  stories :: [Entity Story] <- runDB $ selectList [StoryProject ==. projectId] []
  return $ array $ (toJSON . FlatEntity) `fmap` stories

postStoriesR :: ProjectId -> Handler String
postStoriesR projectId = do
    --TODO: assert project existance and user role on the project
    story :: Story <- requireJsonBody
    assertEqBadRequest $ storyProject story /= projectId
    storyId <- runDB $ insert story
    return $ show storyId

assertEqBadRequest :: Bool -> Handler ()
assertEqBadRequest predicate = when predicate $ sendResponseStatus badRequest400 ()

