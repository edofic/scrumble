module Handler.Projects where

import Import
import Handler.ProjectsProject (getProjectsProjectR)
import qualified Authorization as Auth

getProjectsR :: Handler Value
getProjectsR =  do
    projects :: [Entity Project] <- runDB $ selectList [] []
    return $ array $ (toJSON . FlatEntity) `fmap` projects

postProjectsR :: Handler Value 
postProjectsR = do
  Auth.assert Auth.isAdmin
  insertProject >>= getProjectsProjectR where
    insertProject = runDB $ requireJsonBody >>= insert
