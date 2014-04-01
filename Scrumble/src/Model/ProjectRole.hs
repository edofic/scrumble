module Model.ProjectRole where

import Prelude
import Yesod
import GHC.Generics

data ProjectRole = Developer | ScrumMaster | ProductOwner
            deriving (Eq, Show, Read, Enum, Generic)

derivePersistField "ProjectRole"

instance ToJSON ProjectRole
instance FromJSON ProjectRole
