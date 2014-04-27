module Handler.Stories (getStoriesR, postStoriesR) where

import Import
import qualified Authorization as Auth
import Validation
import Handler.StoriesStory (userStoryValidations)
import Data.Maybe (isJust, isNothing)

getStoriesR :: ProjectId -> Handler Value
getStoriesR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  stories :: [Entity Story] <- runDB $ selectList [StoryProject ==. projectId] []
  return $ array $ (toJSON . FlatEntity) `fmap` stories

postStoriesR :: ProjectId -> Handler ()
postStoriesR projectId = do
  Auth.masterOnly projectId
  story :: Story <- requireJsonBodyWith [("project", toJSON projectId), ("done", toJSON False)]
  runValidationHandler $ do
    userStoryValidations story
    ("done", "New story should not be done") `validate`
      (storyDone story == False)
    ("sprint", "New story should not be assigned") `validate`
      (isNothing $ storySprint story)
  storyIdMby <- runDB $ insertUnique story
  runValidationHandler $ do
    ("title", "Story with supplied title already exists") `validate`
      (isJust storyIdMby)
  return ()
