module Handler.TasksTask (getSprintStoryTaskR, putSprintStoryTaskR) where

import Import
import qualified Authorization as Auth
import Validation
import Data.Maybe (isJust, isNothing, maybe, fromJust)
import Control.Monad (when)
import Model.TaskStatus


getSprintStoryTaskR :: ProjectId -> SprintId -> StoryId -> TaskId -> Handler Value
getSprintStoryTaskR projectId sprintId storyId taskId = do
  Auth.assert $ Auth.memberOfProject projectId
  taskMby <- runDB $ selectFirst [TaskSprint ==. sprintId
                                 ,TaskStory ==. storyId
                                 ,TaskId ==. taskId] []
  task <- maybe notFound return taskMby
  return $ (toJSON . FlatEntity) task



putSprintStoryTaskR :: ProjectId -> SprintId -> StoryId -> TaskId -> Handler ()
putSprintStoryTaskR projectId sprintId storyId taskId = do
  Auth.devOrMaster projectId
  task :: Task <- requireJsonBodyWith [("story", toJSON storyId), ("sprint", toJSON sprintId)]
  runDB $ do
    existingMby <- selectFirst [TaskSprint ==. sprintId
                               ,TaskStory ==. storyId
                               ,TaskId ==. taskId] []
    existing <- maybe notFound return existingMby
    runValidationHandler $ do
      when (isJust $ taskUserId task) $ do
        let userId = fromJust $ taskUserId task
        roleMby <- selectFirst [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId] []
        ("userId", "User must have a role on the project.") `validate` (isJust roleMby)
      ("remaining", "Remaining work must be >= 0.") `validate` ((taskRemaining task) >= 0)
      modifyValications (entityVal existing) task
    replace taskId task
    return ()

modifyValications existing new = case (taskStatus existing) of 
    Unassigned -> do
      when ((taskStatus new) == Assigned) $ ("userId", "Assigning tasks should also set user id.") `validate`
        (isJust $ taskUserId new)
      when ((taskStatus new) == Completed) $ ("status", "Can not set an unassigned task as complete.") `validate` False
      when ((taskStatus new) == Unassigned) $ ("status", "Can not unassign an unassigned task.") `validate` False
      when ((taskStatus new) == Accepted) $ ("status", "Can not set an unassigned task as accepted.") `validate` False
    Assigned   -> do
      when ((taskStatus new) == Unassigned) $ ("status", "Unassigning task should also remove user id.") `validate`
        (isNothing $ taskUserId new)
      when ((taskStatus new) == Completed) $ ("status", "Can not set an unaccepted task as complete.") `validate` False
      when ((taskStatus new) == Accepted) $ ("userId", "Can not accept task when assigned to someone else.") `validate` 
        (((taskUserId existing) == (taskUserId new)) && (isJust $ taskUserId new))
    Completed  -> ("status", "Can not modify completed task") `validate` False
    Accepted   -> do 
      when ((taskStatus new) == Completed) $
        ("remaining", "Remaining work must be 0 before task can be completed.") `validate` ((taskRemaining new) == 0)
      when ((taskStatus new) == Accepted) $ ("userId", "Can not change userId on an accepted task.") `validate` 
        (((taskUserId existing) == (taskUserId new)) && (isJust $ taskUserId new))
      when ((taskStatus new) == Unassigned) $ ("status", "Unassigning task should also remove user id.") `validate`
        (isNothing $ taskUserId new)  

