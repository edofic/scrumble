module Handler.Tasks where

import Import
import qualified Authorization as Auth
import Validation
import Data.Maybe (isJust)

getSprintStoryTasksR :: ProjectId -> SprintId -> StoryId -> Handler Value
getSprintStoryTasksR _ sprintId storyId = do
  tasks <- runDB $ selectList [TaskSprint ==. sprintId
                     ,TaskStory ==. storyId] []
  return $ array $ (toJSON . FlatEntity) `fmap` tasks

postSprintStoryTasksR :: ProjectId -> SprintId -> StoryId -> Handler ()
postSprintStoryTasksR projectId sprintId storyId = do
  task :: Task <- requireJsonBodyWith [("story", toJSON storyId), ("sprint", toJSON sprintId)] 
  _ <- runDB $ do
    storyMby <- selectFirst [StoryId ==. storyId
                            ,StoryProject ==. projectId
                            ,StorySprint ==. Just sprintId] []
    sprintMby <- selectFirst [SprintId ==. sprintId
                             ,SprintProject ==. projectId] []
    runValidationHandler $ do
      ("story", "Story does not exist or not part of this project and/or sprint.") `validate`
        (isJust storyMby)
      ("sprint", "Sprint does not exist or not part of this project.") `validate`
        (isJust sprintMby)
    --TODO: check if sprint is active now (current time is inbetween sprint start and end)
    insert task
  return ()
