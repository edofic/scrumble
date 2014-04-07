module Handler.ProjectUsers where

import Import hiding ((==.))
import Database.Esqueleto hiding (Value)
import qualified Authorization as Auth

getProjectUsersR :: ProjectId -> Handler Value
getProjectUsersR projectId = do
  Auth.assert Auth.isAdmin 
  members <- runDB getMembers
  return $ array $ (toJSON . entityVal) `fmap` members
  where
  getMembers =
    select $ from $ \member -> do
      where_ (member ^. ProjectMemberProject ==. val projectId)
      return member


postProjectUsersR :: ProjectId -> Handler ()
postProjectUsersR projectId = do 
  Auth.assert Auth.isAdmin
  member :: ProjectMember <- requireJsonBody 
  --TODO: assert projectId equality with that from json
  --TODO: assert project existence
  _ <- runDB $ insert member
  return ()

  

