module Handler.Sprint 
( getSprintR
, putSprintR
, validateSprint
) where

import Import
import Control.Monad
import Model.ProjectRole
import Validation
import qualified Authorization as Auth

getSprintR :: ProjectId -> SprintId -> Handler Value
getSprintR projectId sprintId = do
  Auth.assert $ Auth.memberOfProject projectId
  sprintM <- runDB $ get sprintId
  let sprintM' = mfilter ((== projectId) . sprintProject) sprintM    
  maybe notFound 
        (return . toJSON . FlatEntity . Entity sprintId) 
        sprintM'

putSprintR :: ProjectId -> SprintId -> Handler ()
putSprintR projectId sprintId = do
  Auth.assert $ Auth.roleOnProject ScrumMaster projectId
  newSprint :: Sprint <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ validateSprint False newSprint
  runDB $ runValidationHandler $ do
    existing <- count $ overlapping newSprint ++ [SprintId !=. sprintId]
    ("start", "Sprint should not overlap with existing sprints") `validate`
      (existing == 0)
    _ <- insert newSprint    
    return ()
  where
    overlapping (Sprint {sprintStart=start, sprintEnd=end}) = 
      (wraps start ||. wraps end ||. covers start end) ++ [SprintProject ==. projectId]
    wraps x = [SprintStart <=. x, SprintEnd >=. x]
    covers start end = [SprintStart >=. start, SprintEnd <=. end]

validateSprint :: MonadIO m => Bool -> Validation m Sprint
validateSprint new newSprint = do
    currentTime <- liftIO $ currentTimestamp
    ("velocity", "Velocity should be non-negative") `validate` 
      (sprintVelocity newSprint >= 0)
    when new $ ("start", "Start time should be in the future") `validate`
      (sprintStart newSprint >= currentTime)
    ("end", "End time should be after start time") `validate` 
      (sprintEnd newSprint >= sprintStart newSprint)