module Handler.Tasks (getSprintStoryTasksR, postSprintStoryTasksR) where

import Import
import qualified Authorization as Auth
import Validation
import Data.Maybe (isJust, isNothing)
import Model.TaskStatus

getSprintStoryTasksR :: ProjectId -> SprintId -> StoryId -> Handler Value
getSprintStoryTasksR projectId sprintId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  tasks <- runDB $ selectList [TaskSprint ==. sprintId
                     ,TaskStory ==. storyId] []
  return $ array $ (toJSON . FlatEntity) `fmap` tasks

postSprintStoryTasksR :: ProjectId -> SprintId -> StoryId -> Handler ()
postSprintStoryTasksR projectId sprintId storyId = do
  Auth.devOrMaster projectId
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
      --("remaining", "Remaining work must be more than 0.") `validate`
      --  (taskRemaining task > 0)
      ("status", "New task should not be Completed.") `validate`
        ((taskStatus task) /= Completed)
      ("status", "New task should not be Accepted.") `validate`
        ((taskStatus task) /= Accepted)
      if (taskStatus task) == Unassigned 
        then
          ("user", "Unassigned task must not have a defined user.") `validate`
            (isNothing $ taskUserId task)
        else 
          do
            ("user", "Assigned task must have a defined user.") `validate`
              (isJust $ taskUserId task)
            --TODO: validate user role on project
            return ()

    --TODO: check if sprint is active now (current time is inbetween sprint start and end)
    insert task
  return ()


