module Handler.StoriesStory where

import Import  
import qualified Authorization as Auth
import Model.ProjectRole
import Validation
import Control.Monad (when)
import Data.Maybe (isJust)
import qualified Handler.SprintStory as SprintStory

getStoriesStoryR :: ProjectId -> StoryId -> Handler Value
getStoriesStoryR projectId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  storyMby <- runDB $ selectFirst [StoryId ==. storyId, StoryProject ==. projectId] []
  story <- maybe notFound return storyMby
  return $ (toJSON . FlatEntity) story

assertionOwnerMaster :: ProjectId -> Auth.Check Bool
assertionOwnerMaster projectId = (Auth.roleOnProject ProductOwner projectId) .||. (Auth.roleOnProject ScrumMaster projectId)

userStoryValidations :: Validation m Story
userStoryValidations story = 
  ("businessValue", "Business value should be non-negative") `validate`
    (storyBusinessValue story >= 0)

putStoriesStoryR :: ProjectId -> StoryId -> Handler ()
putStoriesStoryR projectId storyId = do
  Auth.assert $ assertionOwnerMaster projectId
  story <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ userStoryValidations story
  runDB $ runValidationHandler $ do
    existingM <- get storyId
    flip (maybe (return ())) existingM $ \existing -> 
      when ((storySprint existing /= storySprint story) && (isJust $ storySprint story)) -- assigning story to sprint
           (SprintStory.validateSprintStoryAssignment story)

  runDB $ runValidationHandler $ do
    existing <- count [StoryTitle ==. (storyTitle story), StoryId !=. storyId]
    ("title", "Story with supplied title already exists") `validate` (existing == 0)
    when (existing == 0) $ replace storyId story
  return ()

deleteStoriesStoryR :: ProjectId -> StoryId -> Handler ()
deleteStoriesStoryR projectId storyId = do
  Auth.assert $ assertionOwnerMaster projectId
  runDB $ deleteWhere [StoryId ==. storyId, StoryProject ==. projectId] 

