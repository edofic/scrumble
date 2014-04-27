module Handler.SprintStory where

import Import
import Data.Maybe (isJust, isNothing)
import Validation
import qualified Authorization as Auth

putSprintStoryR :: ProjectId -> SprintId -> StoryId -> Handler ()
putSprintStoryR projectId sprintId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  runDB $ updateWhere [StoryProject ==. projectId, StoryId ==. storyId] 
                      [StorySprint =. Just sprintId]

validateSprintStoryAssignment :: Validation m Story
validateSprintStoryAssignment story = do
  ("points", "A story without time complexity cannot be assigned") `validate`
    (isJust $ storyPoints story)
  ("done", "A done story cannot be assigned to a new sprint") `validate`
    (storyDone story == False)
  ("sprint", "This story is already assigned") `validate`
    (isNothing $ storySprint story)

deleteSprintStoryR :: ProjectId -> SprintId -> StoryId -> Handler ()
deleteSprintStoryR projectId sprintId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  runDB $ updateWhere [StoryProject ==. projectId, StorySprint ==. Just sprintId, StoryId ==. storyId] 
                      [StorySprint =. Nothing]