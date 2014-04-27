module Handler.Sprint (getSprintR) where

import Import
import Control.Monad
import qualified Authorization as Auth

getSprintR :: ProjectId -> SprintId -> Handler Value
getSprintR projectId sprintId = do
  Auth.assert $ Auth.memberOfProject projectId
  sprintM <- runDB $ get sprintId
  let sprintM' = mfilter ((== projectId) . sprintProject) sprintM    
  maybe notFound 
        (return . toJSON . FlatEntity . Entity sprintId) 
        sprintM'
