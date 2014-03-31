module Handler.Projects where

import Import
import Handler.ProjectsProject (getProjectsProjectR)

getProjectsR :: Handler Value
getProjectsR = runDB $ do
    projects :: [Entity Project] <- selectList [] []
    return $ array $ (toJSON . FlatEntity) `fmap` projects

postProjectsR :: Handler Value 
postProjectsR = insertProject >>= getProjectsProjectR where
    insertProject = runDB $ requireJsonBody >>= insert
