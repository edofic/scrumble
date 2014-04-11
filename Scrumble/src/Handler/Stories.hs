module Handler.Stories (getStoriesR, postStoriesR) where

import Import
import qualified Authorization as Auth
import Validation
import Handler.StoriesStory (userStoryValidations, assertionOwnerMaster)
import Data.Maybe (isJust)

getStoriesR :: ProjectId -> Handler Value
getStoriesR projectId = do
  Auth.assertM $ Auth.memberOfProject projectId
  stories :: [Entity Story] <- runDB $ selectList [StoryProject ==. projectId] []
  return $ array $ (toJSON . FlatEntity) `fmap` stories

postStoriesR :: ProjectId -> Handler ()
postStoriesR projectId = do
  Auth.assertM $ assertionOwnerMaster projectId
  story :: Story <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ userStoryValidations story
  storyIdMby <- runDB $ insertUnique story
  runValidationHandler $ do
    ("title", "Story with supplied title already exists") `validate`
      (isJust storyIdMby)
  return ()
