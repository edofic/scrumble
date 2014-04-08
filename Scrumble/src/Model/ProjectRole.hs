module Model.ProjectRole where

import Prelude
import Yesod
import GHC.Generics
import Data.List (elem, nub, sort)

data ProjectRole = Developer | ScrumMaster | ProductOwner
            deriving (Eq, Ord, Show, Read, Enum, Generic)

derivePersistField "ProjectRole"

instance ToJSON ProjectRole
instance FromJSON ProjectRole

checkRoleCombination :: [ProjectRole] -> Bool
checkRoleCombination = check . sort . nub where
  check [Developer, ProductOwner] = True
  check [Developer, ScrumMaster]  = True
  check [_] = True
  check  _  = False