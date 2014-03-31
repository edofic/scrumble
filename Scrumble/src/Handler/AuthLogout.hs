module Handler.AuthLogout (postAuthLogoutR) where

import Import

postAuthLogoutR :: Handler ()
postAuthLogoutR = clearSession