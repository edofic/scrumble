module Handler.ProjectDocs where

import Import
import qualified Authorization as Auth

getProjectDocsR :: ProjectId -> Handler Value
getProjectDocsR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  docsMby <- runDB $ selectFirst [ProjectDocsProject ==. projectId] [Desc ProjectDocsId]
  return $ toJSON $ maybe (ProjectDocs projectId "") entityVal docsMby

putProjectDocsR :: ProjectId -> Handler ()
putProjectDocsR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  docs :: ProjectDocs <- requireJsonBodyWith [("project", toJSON projectId)]
  runDB $ insert docs
  return ()
