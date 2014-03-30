module Authorization where

import Import
import Control.Monad (when)
import Yesod.Auth (maybeAuth)
import Network.HTTP.Types.Status (unauthorized401)
import Model.Role

unauthorized :: MonadHandler m => m a
unauthorized = sendResponseStatus unauthorized401 ()

currentUser :: Handler (Entity User)
currentUser = do
  mauth <- maybeAuth
  maybe unauthorized return mauth

assertM :: (Entity User -> Handler Bool) -> Handler ()
assertM f = do
  user <- currentUser
  ok <- f user
  when (not ok) unauthorized

assert :: (Entity User -> Bool) -> Handler ()
assert = assertM . (return .)

isAdmin :: Entity User -> Bool
isAdmin (Entity _ user) = userRole user == Administrator

hasUserId :: UserId -> Entity User -> Bool
hasUserId wanted (Entity userId _) = userId == wanted
