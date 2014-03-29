module Handler.ProjectsProject where

import Import

getProjectsProjectR :: ProjectId -> Handler Value
getProjectsProjectR projectId = runDB $ do
    projectEntity <- selectFirst [ProjectId ==. projectId] []
    maybe notFound (return . toJSON . FlatEntity) projectEntity

deleteProjectsProjectR :: ProjectId -> Handler ()
deleteProjectsProjectR projectId = runDB $ delete projectId >> return ()


putProjectsProjectR :: ProjectId -> Handler ()
putProjectsProjectR projectId = runDB $ do
    updated :: Project <- requireJsonBody
    replace projectId updated
                             
                             
                             
                             
