module Handler.ProjectsProject where

import Import
import qualified Authorization as Auth

getProjectsProjectR :: ProjectId -> Handler Value
getProjectsProjectR projectId = do
    projectEntity <- runDB $ selectFirst [ProjectId ==. projectId] []
    maybe notFound (return . toJSON . FlatEntity) projectEntity

deleteProjectsProjectR :: ProjectId -> Handler ()
deleteProjectsProjectR projectId = do
  Auth.assert Auth.isAdmin
  runDB $ delete projectId >> return ()


putProjectsProjectR :: ProjectId -> Handler ()
putProjectsProjectR projectId =  do
  Auth.assert Auth.isAdmin
  updated :: Project <- requireJsonBody
  runDB $ replace projectId updated
                             
                             
                             
                             
