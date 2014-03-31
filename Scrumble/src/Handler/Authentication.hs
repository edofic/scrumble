module Handler.Authentication (postAuthenticationR, getAuthUserR) where

import Import
import Yesod.Auth 
import GHC.Generics (Generic)
import Crypto.PasswordStore (verifyPassword)
import Data.Text.Encoding (encodeUtf8)
import Authorization

data AuthRequest = AuthRequest { username :: Text
                               , password :: Text     
                               } deriving Generic
instance FromJSON AuthRequest

postAuthenticationR :: Handler ()
postAuthenticationR = do
  AuthRequest username givenPassword <- requireJsonBody
  mpass <- runDB $ getBy $ UniqueUserAuth username
  flip (maybe notFound) mpass $ \entity -> 
    let realPass = userAuthPassword $ entityVal entity
        passOk = verifyPassword (encodeUtf8 givenPassword) (encodeUtf8 realPass)
    in  if passOk then 
          setCreds False $ Creds "jsonPost" username []
        else 
          unauthorized

getAuthUserR :: Handler Value
getAuthUserR = do
  userEntity <- currentUser
  return . toJSON $ FlatEntity userEntity
