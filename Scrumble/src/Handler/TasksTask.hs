module Handler.TasksTask (getSprintStoryTaskR, putSprintStoryTaskR) where

import Import
import qualified Authorization as Auth
import Validation
import Data.Maybe (isJust, maybe)
import Control.Monad (when)
import Model.TaskStatus


getSprintStoryTaskR :: ProjectId -> SprintId -> StoryId -> TaskId -> Handler Value
getSprintStoryTaskR _ sprintId storyId taskId = do
  --TODO: validate authentication
  --TODO: validate that user is on the project (also implies project existance)
  taskMby <- runDB $ selectFirst [TaskSprint ==. sprintId
                                 ,TaskStory ==. storyId
                                 ,TaskId ==. taskId] []
  task <- maybe notFound return taskMby
  return $ (toJSON . FlatEntity) task



putSprintStoryTaskR :: ProjectId -> SprintId -> StoryId -> TaskId -> Handler ()
putSprintStoryTaskR projectId sprintId storyId taskId = do
  task :: Task <- requireJsonBodyWith [("story", toJSON storyId), ("sprint", toJSON sprintId)]
  runDB $ do
    existingMby <- selectFirst [TaskSprint ==. sprintId
                               ,TaskStory ==. storyId
                               ,TaskId ==. taskId] []
    existing <- maybe notFound return existingMby
    --TODO: validations
    replace taskId task
    return ()

