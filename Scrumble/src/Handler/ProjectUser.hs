module Handler.ProjectUser where

import Import
import Data.List (nub)
import Validation
import qualified Authorization as Auth
import Handler.ProjectUsers (userRolesValidation)

getProjectUserR :: ProjectId -> UserId -> Handler Value
getProjectUserR projectId userId = do
  Auth.assertM $ Auth.memberOfProject projectId
  role <- runDB $ selectFirst [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId] []
  maybe notFound (return . toJSON . entityVal) role


putProjectUserR :: ProjectId -> UserId -> Handler ()
putProjectUserR projectId userId = do
  Auth.assert Auth.isAdmin
  maybeMember <- runDB $ selectFirst [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId] []
  member <- maybe notFound return maybeMember
  nmemberRaw :: ProjectMember <- requireJsonBodyWith [("project", toJSON projectId), ("user", toJSON userId)]
  let nmember = nmemberRaw { projectMemberRoles = nub $ projectMemberRoles nmemberRaw}
  runValidationHandler $ userRolesValidation $ projectMemberRoles nmember
  runDB $ replace (entityKey member) nmember


deleteProjectUserR :: ProjectId -> UserId -> Handler ()
deleteProjectUserR projectId userId = do
  Auth.assert Auth.isAdmin
  runDB $ deleteWhere [ProjectMemberProject ==. projectId, ProjectMemberUser ==. userId]


