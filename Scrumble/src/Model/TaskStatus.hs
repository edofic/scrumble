module Model.TaskStatus where

import Prelude
import Yesod
import GHC.Generics

data TaskStatus = Unassigned | Assigned | Accepted | Completed 
  deriving (Eq, Show, Read, Generic)

derivePersistField "TaskStatus"

instance ToJSON TaskStatus
instance FromJSON TaskStatus

