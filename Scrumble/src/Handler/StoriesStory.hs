module Handler.StoriesStory 
(getStoriesStoryR
,putStoriesStoryR
,deleteStoriesStoryR
,userStoryValidations) where

import Import  hiding ((.||.))
import qualified Authorization as Auth
import Authorization ((.||.))
import Model.ProjectRole
import Validation

getStoriesStoryR :: ProjectId -> StoryId -> Handler Value
getStoriesStoryR projectId storyId = do
  Auth.assertM $ Auth.memberOfProject projectId
  storyMby <- runDB $ selectFirst [StoryId ==. storyId, StoryProject ==. projectId] []
  story <- maybe notFound return storyMby
  return $ (toJSON . FlatEntity) story

assertionOwnerMaster :: ProjectId -> (Entity User -> Handler Bool)
assertionOwnerMaster projectId = (Auth.roleOnProject ProductOwner projectId) .||. (Auth.roleOnProject ScrumMaster projectId)

userStoryValidations story = do
  ("businessValue", "Business value should be non-negative") `validate`
    (storyBusinessValue story >= 0)

putStoriesStoryR :: ProjectId -> StoryId -> Handler ()
putStoriesStoryR projectId storyId = do
  Auth.assertM $ assertionOwnerMaster projectId
  story <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ userStoryValidations story
  runDB $ replace storyId story

deleteStoriesStoryR :: ProjectId -> StoryId -> Handler ()
deleteStoriesStoryR projectId storyId = do
  Auth.assertM $ assertionOwnerMaster projectId
  runDB $ deleteWhere [StoryId ==. storyId, StoryProject ==. projectId] 

