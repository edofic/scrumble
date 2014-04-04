module Model.StoryPriority where

import Prelude
import Yesod
import GHC.Generics

data StoryPriority = NotThisTime | CouldHave | ShouldHave | MustHave 
		     deriving (Eq, Ord, Show, Read, Enum, Generic)
		     
derivePersistField "StoryPriority"

instance ToJSON StoryPriority
instance FromJSON StoryPriority
