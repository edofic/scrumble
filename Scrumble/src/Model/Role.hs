module Model.Role where

import Prelude
import Yesod
import GHC.Generics

data Role = RegularUser | Administrator 
            deriving (Eq, Show, Read, Enum, Generic)

derivePersistField "Role"

instance ToJSON Role
instance FromJSON Role
