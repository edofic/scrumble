module Handler.SprintStory where

import Import
import qualified Authorization as Auth

putSprintStoryR :: ProjectId -> SprintId -> StoryId -> Handler ()
putSprintStoryR projectId sprintId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  runDB $ updateWhere [StoryProject ==. projectId, StoryId ==. storyId] 
                      [StorySprint =. Just sprintId]

deleteSprintStoryR :: ProjectId -> SprintId -> StoryId -> Handler ()
deleteSprintStoryR projectId sprintId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  runDB $ updateWhere [StoryProject ==. projectId, StorySprint ==. Just sprintId, StoryId ==. storyId] 
                      [StorySprint =. Nothing]