module Handler.AuthUser (getAuthUserR) where

import Import
import Authorization

getAuthUserR :: Handler Value
getAuthUserR = (toJSON . FlatEntity) `fmap` currentUser
