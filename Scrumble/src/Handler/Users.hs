module Handler.Users where

import Import
import Handler.UsersUser (getUsersUserR)

getUsersR :: Handler Value
getUsersR = runDB $ do
  users :: [Entity User] <- selectList [] [] 
  return $ array $ (toJSON . FlatEntity) `fmap` users

postUsersR :: Handler Value
postUsersR = insertUser >>= getUsersUserR where
  insertUser = runDB $ requireJsonBody >>= insert
    
