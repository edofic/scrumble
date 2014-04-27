module Handler.UsersUserPassword (postUsersUserPasswordR) where

import Import
import Crypto.PasswordStore (makePassword)
import Control.Monad.Maybe
import Data.Text.Encoding (encodeUtf8, decodeUtf8)
import GHC.Generics (Generic)

import qualified Authorization as Auth

data PasswordRequest = PasswordRequest { newPassword :: Text }
                                       deriving Generic

instance FromJSON PasswordRequest

postUsersUserPasswordR :: UserId -> Handler ()
postUsersUserPasswordR userId = do
  Auth.assert $ Auth.hasUserId userId
  PasswordRequest newPassword <- requireJsonBody
  hashed <- liftIO $ decodeUtf8 `fmap` makePassword (encodeUtf8 newPassword) 14
  ok <- runDB $ runMaybeT $ do
    user <- MaybeT $ get userId
    let username = userUsername user
        newAuth = UserAuth username hashed
    curAuth <- lift $ getBy $ UniqueUserAuth username
    lift $ maybe (insert_ newAuth) 
                 (\(Entity key _) -> replace key newAuth) 
                 curAuth
  maybe notFound return ok

