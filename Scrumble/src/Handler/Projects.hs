module Handler.Projects where

import Import hiding ((==.))
import Handler.ProjectsProject (getProjectsProjectR)
import Database.Esqueleto hiding (Value)
import qualified Authorization as Auth
import Data.Maybe (isJust, fromJust)
import Validation

getProjectsR :: Handler Value
getProjectsR = do
  user@(Entity userId _)  <- Auth.currentUser
  projects <- runDB $ if Auth.isAdmin user
    then getAdminProjectQ
    else getProjectsQ userId
  return $ array $ (toJSON . FlatEntity) `fmap` projects
  where
    getProjectsQ userId = 
      select $
      from $ \(member `InnerJoin` project) -> do
        on (member ^. ProjectMemberProject ==. project ^. ProjectId)
        where_ (member ^. ProjectMemberUser ==. val userId)
        return project
    getAdminProjectQ = selectList [] [] 

postProjectsR :: Handler Value 
postProjectsR = do
  Auth.assert Auth.isAdmin
  project <- requireJsonBody
  projectIdMyb <- runDB $ insertUnique project
  runValidationHandler $ do
    ("name", "Project with supplied name allready exists") `validate`
      (isJust projectIdMyb)
  getProjectsProjectR $ fromJust projectIdMyb
