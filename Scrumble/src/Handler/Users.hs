module Handler.Users where

import Import
import Handler.UsersUser (getUsersUserR)

import qualified Authorization as Auth

getUsersR :: Handler Value
getUsersR = do
  Auth.assert Auth.isAdmin
  users :: [Entity User] <- runDB $ selectList [] [] 
  return $ array $ (toJSON . FlatEntity) `fmap` users

postUsersR :: Handler Value
postUsersR = do
  Auth.assert Auth.isAdmin
  insertUser >>= getUsersUserR 
  where
    insertUser = runDB $ requireJsonBody >>= insert
    
