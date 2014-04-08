module Handler.Stories (getStoriesR, postStoriesR) where

import Import
import qualified Authorization as Auth
import Validation
import Handler.StoriesStory (userStoryValidations)

getStoriesR :: ProjectId -> Handler Value
getStoriesR projectId = do
  Auth.assertM $ Auth.memberOfProject projectId
  stories :: [Entity Story] <- runDB $ selectList [StoryProject ==. projectId] []
  return $ array $ (toJSON . FlatEntity) `fmap` stories

postStoriesR :: ProjectId -> Handler String
postStoriesR projectId = do
  Auth.assertM $ Auth.memberOfProject projectId
  story :: Story <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ userStoryValidations story
  storyId <- runDB $ insert story
  return $ show storyId
