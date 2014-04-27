module Handler.ProjectUsers where

import Import
import Validation
import Model.ProjectRole
import Data.List (nub)
import qualified Authorization as Auth
import Data.Maybe (isJust)

getProjectUsersR :: ProjectId -> Handler Value
getProjectUsersR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  members <- runDB getMembers
  return $ array $ (toJSON . entityVal) `fmap` members
  where
  getMembers = selectList [ProjectMemberProject ==. projectId] []


postProjectUsersR :: ProjectId -> Handler ()
postProjectUsersR projectId = do 
  Auth.adminOnly
  memberRaw :: ProjectMember <- requireJsonBodyWith [("project", toJSON projectId)]
  let member = memberRaw { projectMemberRoles = nub $ projectMemberRoles memberRaw}
  runValidationHandler $ userRolesValidation $ projectMemberRoles member
  memberIdMyb <- runDB $ insertUnique member
  runValidationHandler $ do
    ("error", "Member for this project already exists") `validate`
      (isJust memberIdMyb)
  return ()
 
userRolesValidation :: Validation m [ProjectRole]
userRolesValidation roles = do
  ("roles", "Bad combination of roles") `validate` 
    checkRoleCombination roles
