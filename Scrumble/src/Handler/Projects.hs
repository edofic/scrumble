module Handler.Projects where

import Import hiding ((==.))
import Handler.ProjectsProject (getProjectsProjectR)
import Database.Esqueleto hiding (Value)
import qualified Authorization as Auth

getProjectsR :: Handler Value
getProjectsR = do
  Entity userId _  <- Auth.currentUser
  projects <- runDB $ getProjectsQ userId
  return $ array $ (toJSON . FlatEntity) `fmap` projects
  where
    getProjectsQ userId = 
      select $
      from $ \(member `InnerJoin` project) -> do
        on (member ^. ProjectMemberProject ==. project ^. ProjectId)
        where_ (member ^. ProjectMemberUser ==. val userId)
        return project

postProjectsR :: Handler Value 
postProjectsR = do
  Auth.assert Auth.isAdmin
  insertProject >>= getProjectsProjectR where
    insertProject = runDB $ requireJsonBody >>= insert
