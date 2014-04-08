module Authorization where

import Import
import Control.Monad (when)
import Yesod.Auth (maybeAuth)
import Network.HTTP.Types.Status (unauthorized401)
import Model.Role
import Data.Maybe (isJust)
import Model.ProjectRole

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

memberOfProject :: ProjectId -> Entity User -> Handler Bool
memberOfProject projectId (Entity userId _) = 
  fmap isJust $ runDB $ getBy $ UniqueMember userId projectId

roleOnProject :: ProjectRole -> ProjectId -> Entity User -> Handler Bool
roleOnProject role projectId (Entity userId _) = 
  fmap isOk $ runDB $ getBy $ UniqueMember userId projectId where
    isOk (Just (Entity _ member)) = projectMemberRole member == role
    isOk _ = False


handlerBinComb :: (Bool -> Bool -> Bool) -> (Entity User -> Handler Bool) -> (Entity User -> Handler Bool) -> Entity User -> Handler Bool
handlerBinComb op h1 h2 = \user -> do
  b1 <- h1 user
  b2 <- h2 user
  return $ op b1 b2

(.||.) = handlerBinComb (||)
(.&&.) = handlerBinComb (&&)

