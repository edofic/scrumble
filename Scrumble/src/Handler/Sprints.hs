module Handler.Sprints 
( getSprintsR
, postSprintsR
) where

import Import hiding ((==.))
import Database.Esqueleto hiding (Value)
import Model.ProjectRole
import Validation
import qualified Authorization as Auth

getSprintsR :: ProjectId -> Handler Value
getSprintsR projectId = do 
  Auth.assertM $ Auth.memberOfProject projectId
  sprints <- runDB $ 
    select $ from $ \sprint -> do
      where_ (sprint ^. SprintProject ==. val projectId)
      return sprint
  return $ array $ FlatEntity `map` sprints

postSprintsR :: ProjectId -> Handler Value
postSprintsR projectId = do
  Auth.assertM $ Auth.roleOnProject ScrumMaster projectId
  newSprint :: Sprint <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ do
    ("velocity", "Velocity should be non-negative") `validate` 
      (sprintVelocity newSprint >= 0)
    ("end", "End time should be after start time") `validate` 
      (sprintEnd newSprint >= sprintStart newSprint)
  sprintId <- runDB $ insert newSprint
  return $ toJSON $ FlatEntity $ Entity sprintId newSprint
