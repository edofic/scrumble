module Handler.Sprints 
( getSprintsR
, postSprintsR
) where

import Import 
import Model.ProjectRole
import Validation
import Handler.Sprint (validateSprint)
import qualified Authorization as Auth

getSprintsR :: ProjectId -> Handler Value
getSprintsR projectId = do 
  Auth.assert $ Auth.memberOfProject projectId
  sprints <- runDB $ selectList [SprintProject ==. projectId] []
  return $ array $ FlatEntity `map` sprints

postSprintsR :: ProjectId -> Handler Value
postSprintsR projectId = do
  Auth.assert $ Auth.roleOnProject ScrumMaster projectId
  newSprint :: Sprint <- requireJsonBodyWith [("project", toJSON projectId)]
  runValidationHandler $ validateSprint False newSprint
  sprintId <- runDB $ runValidationHandler $ do
    existing <- count (overlapping newSprint) 
    ("start", "Sprint should not overlap with existing sprints") `validate`
      (existing == 0)
    insert newSprint    
  return $ toJSON $ FlatEntity $ Entity sprintId newSprint
  where
    overlapping (Sprint {sprintStart=start, sprintEnd=end}) = 
      (wraps start ||. wraps end ||. covers start end) ++ [SprintProject ==. projectId]
    wraps x = [SprintStart <=. x, SprintEnd >=. x]
    covers start end = [SprintStart >=. start, SprintEnd <=. end]
