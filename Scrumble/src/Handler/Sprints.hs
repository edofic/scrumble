module Handler.Sprints 
( getSprintsR
, postSprintsR
) where

import Import 
import Model.ProjectRole
import Validation
import qualified Authorization as Auth

getSprintsR :: ProjectId -> Handler Value
getSprintsR projectId = do 
  Auth.assertM $ Auth.memberOfProject projectId
  sprints <- runDB $ selectList [SprintProject ==. projectId] []
  return $ array $ FlatEntity `map` sprints

postSprintsR :: ProjectId -> Handler Value
postSprintsR projectId = do
  Auth.assertM $ Auth.roleOnProject ScrumMaster projectId
  newSprint :: Sprint <- requireJsonBodyWith [("project", toJSON projectId)]
  currentTime <- liftIO $ currentTimestamp
  runValidationHandler $ do
    ("velocity", "Velocity should be non-negative") `validate` 
      (sprintVelocity newSprint >= 0)
    ("start", "Start time should be in the future") `validate`
      (sprintStart newSprint >= currentTime)
    ("end", "End time should be after start time") `validate` 
      (sprintEnd newSprint >= sprintStart newSprint)
  sprintId <- runDB $ runValidationHandler $ do
    existing <- count (overlapping newSprint) 
    ("start", "Sprint should not overlap with existing sprints") `validate`
      (existing == 0)
    insert newSprint
  return $ toJSON $ FlatEntity $ Entity sprintId newSprint
  where
    overlapping (Sprint {sprintStart=start, sprintEnd=end}) = 
      wraps start ||. wraps end ||. covers start end
    wraps x = [SprintStart <. x, SprintEnd >. x]
    covers start end = [SprintStart >. start, SprintEnd <. end ]
