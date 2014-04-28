module Handler.Authentication (postAuthenticationR) where

import Import
import Yesod.Auth 
import GHC.Generics (Generic)
import Crypto.PasswordStore (verifyPassword)
import Data.Text.Encoding (encodeUtf8)
import Network.HTTP.Types.Status (unauthorized401, notFound404)

data AuthRequest = AuthRequest { username :: Text
                               , password :: Text     
                               } deriving Generic
instance FromJSON AuthRequest

postAuthenticationR :: Handler ()
postAuthenticationR = do
  AuthRequest username givenPassword <- requireJsonBody
  mpass <- runDB $ getBy $ UniqueUserAuth username
  flip (maybe notFoundMsg) mpass $ \entity -> 
    let realPass = userAuthPassword $ entityVal entity
        passOk = verifyPassword (encodeUtf8 givenPassword) (encodeUtf8 realPass)
    in  if passOk then 
          setCreds False $ Creds "jsonPost" username []
        else 
          unauthorizedMsg
  where
    unauthorizedMsg = sendResponseStatus unauthorized401 $ object 
      [("message" :: Text, toJSON ("Login failed. Wrong password." :: Text))]
    notFoundMsg = sendResponseStatus notFound404 $ object
      [("message" :: Text, toJSON ("Login failed. User not found." :: Text))]
