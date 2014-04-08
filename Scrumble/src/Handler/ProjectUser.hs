module Handler.ProjectUser where

import Import
import qualified Authorization as Auth

getProjectUserR :: ProjectId -> UserId -> Handler Value
getProjectUserR projectId userId = do
  Auth.assert Auth.isAdmin
  role <- runDB $ selectFirst [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId] []
  maybe notFound (return . toJSON . entityVal) role


putProjectUserR :: ProjectId -> UserId -> Handler ()
putProjectUserR projectId userId = do
  Auth.assert Auth.isAdmin
  maybeMember <- runDB $ selectFirst [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId] []
  member <- maybe notFound return maybeMember
  nmember :: ProjectMember <- requireJsonBody
  runDB $ replace (entityKey member) nmember


deleteProjectUserR :: ProjectId -> UserId -> Handler ()
deleteProjectUserR projectId userId = do
  Auth.assert Auth.isAdmin
  runDB $ deleteWhere [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId]


