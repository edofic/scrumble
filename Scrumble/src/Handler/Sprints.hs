module Handler.Sprints 
( getSprintsR
, postSprintsR
) where

import Import hiding ((==.))
import Database.Esqueleto hiding (Value)
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
  Auth.assertM $ Auth.memberOfProject projectId
  newSprint :: Sprint <- requireJsonBodyWith [("projectId", toJSON projectId)]
  sprintId <- runDB $ insert newSprint
  return $ toJSON $ FlatEntity $ Entity sprintId newSprint

