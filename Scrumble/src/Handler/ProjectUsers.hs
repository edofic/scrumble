module Handler.ProjectUsers where

import Import
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
  member :: ProjectMember <- requireJsonBody 
  --TODO: assert projectId equality with that from json
  --TODO: assert project existence
  _ <- runDB $ insert member
  return ()

  

