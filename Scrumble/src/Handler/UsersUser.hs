module Handler.UsersUser where

import Import

import qualified Authorization as Auth

getUsersUserR :: UserId -> Handler Value
getUsersUserR userId = do
  _ <- Auth.currentUser
  userEntity <- runDB $ selectFirst [UserId ==. userId] []
  maybe notFound (return . toJSON . FlatEntity) userEntity

putUsersUserR :: UserId -> Handler ()
putUsersUserR userId = do
  Auth.adminOnly
  user <- requireJsonBody
  runDB $ do
    replace userId user
    updateWhere [UserAuthUsername ==. userUsername user] 
                [UserAuthUsername =. userUsername user]


deleteUsersUserR :: UserId -> Handler ()
deleteUsersUserR userId = do
  Auth.adminOnly
  runDB $ delete userId >> return ()