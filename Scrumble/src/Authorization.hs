module Authorization where

import Import
import Control.Monad (when)
import Control.Applicative
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

newtype Check a = Check { runCheck :: Entity User -> Handler a }
                  deriving (Functor)

pureCheck :: (Entity User -> a) -> Check a
pureCheck f = Check $ return . f

instance Applicative Check where
  pure = Check . const . return
  Check f <*> Check x = 
    Check $ \user -> f user <*> x user

assert :: Check Bool -> Handler ()
assert (Check f) = do
  user <- currentUser
  ok <- f user
  when (not ok && (not $ isAdmin user)) unauthorized

isAdmin :: Entity User -> Bool
isAdmin (Entity _ user) = userRole user == Administrator

hasUserId :: UserId -> Check Bool
hasUserId wanted = Check $ \(Entity userId _) -> return $
  userId == wanted

memberOfProject :: ProjectId -> Check Bool
memberOfProject projectId = Check $ \(Entity userId _) ->
  fmap isJust $ runDB $ getBy $ UniqueMember userId projectId

roleOnProject :: ProjectRole -> ProjectId -> Check Bool
roleOnProject role = rolesOnProject [role]

rolesOnProject :: [ProjectRole] -> ProjectId -> Check Bool
rolesOnProject roles projectId = Check $ \(Entity userId _) ->
  fmap isOk $ runDB $ getBy $ UniqueMember userId projectId where
    isOk (Just (Entity _ member)) = any (`elem` projectMemberRoles member) roles
    isOk _ = False

adminOnly :: Handler ()
adminOnly = assert $ pureCheck isAdmin

masterOnly :: ProjectId -> Handler ()
masterOnly = assert . rolesOnProject [ScrumMaster, ProductOwner] 
