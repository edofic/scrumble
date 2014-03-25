module Handler.UsersUser where

import Import

getUsersUserR :: UserId -> Handler Value
getUsersUserR userId = runDB $ do
  userEntity <- selectFirst [UserId ==. userId] []
  maybe notFound (return . toJSON . FlatEntity) userEntity

deleteUsersUserR :: UserId -> Handler ()
deleteUsersUserR userId = runDB $ delete userId >> return ()