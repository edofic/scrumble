module Handler.ProjectsProject where

import Import hiding ((==.))
import Database.Esqueleto hiding (Value, delete)
import Data.Maybe (listToMaybe)
import qualified Authorization as Auth

getProjectsProjectR :: ProjectId -> Handler Value
getProjectsProjectR projectId = do
  Entity userId _ <- Auth.currentUser
  project <- runDB $ getProjectQ userId
  maybe notFound (return . toJSON . FlatEntity) project 
  where
    getProjectQ userId = listToMaybe `fmap` do
      select $
        from $ \(member `InnerJoin` project) -> do
        on (member ^. ProjectMemberProject ==. project ^. ProjectId)
        where_ 
          ((member ^. ProjectMemberUser ==. val userId) 
            &&.
          (project ^. ProjectId ==. val projectId))
        return project


deleteProjectsProjectR :: ProjectId -> Handler ()
deleteProjectsProjectR projectId = do
  Auth.assert Auth.isAdmin
  runDB $ delete projectId >> return ()


putProjectsProjectR :: ProjectId -> Handler ()
putProjectsProjectR projectId =  do
  Auth.assert Auth.isAdmin
  updated :: Project <- requireJsonBody
  runDB $ replace projectId updated
                             
                             
                             
                             
