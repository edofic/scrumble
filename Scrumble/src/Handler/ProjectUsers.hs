module Handler.ProjectUsers where

import Import
import Validation
import Model.ProjectRole
import Data.List (nub)
import qualified Authorization as Auth

getProjectUsersR :: ProjectId -> Handler Value
getProjectUsersR projectId = do
  Auth.assertM $ Auth.memberOfProject projectId
  members <- runDB getMembers
  return $ array $ (toJSON . entityVal) `fmap` members
  where
  getMembers = selectList [ProjectMemberProject ==. projectId] []


postProjectUsersR :: ProjectId -> Handler ()
postProjectUsersR projectId = do 
  Auth.assert Auth.isAdmin
  memberRaw :: ProjectMember <- requireJsonBodyWith [("project", toJSON projectId)]
  let member = memberRaw { projectMemberRoles = nub $ projectMemberRoles member}
  runValidationHandler $ userRolesValidation $ projectMemberRoles member
  runDB $ insert member
  return ()
 
userRolesValidation :: Validation m [ProjectRole]
userRolesValidation roles = do
  ("roles", "Bad combination of roles") `validate` 
    checkRoleCombination roles