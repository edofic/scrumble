{-# LANGUAGE UndecidableInstances #-}

module Model where

import Prelude
import Yesod
import Data.Text (Text)
import Database.Persist.Quasi
import Data.Typeable (Typeable)
import Data.Int (Int64)
import Control.Applicative 
import Model.Role
import Model.ProjectRole
import Model.StoryPriority
import Model.TaskStatus

import qualified Data.HashMap.Strict as Hash

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share [mkPersist sqlOnlySettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")


newtype FlatEntity val = FlatEntity { unFlatEntity :: Entity val}
                         deriving (Eq, Ord, Read, Show)

instance (ToJSON val,  ToJSON (Entity val)) => ToJSON (FlatEntity val) where
  toJSON (FlatEntity entity@(Entity key val)) = 
    case toJSON val of
      Object hash -> Object $ Hash.insert "id" (toJSON key) hash
      _           -> toJSON entity

instance (FromJSON val, FromJSON (Key val), FromJSON (Entity val)) => FromJSON (FlatEntity val) where
  parseJSON value@(Object obj) = 
    fmap FlatEntity $ Entity
                        <$> obj .: "id" 
                        <*> parseJSON value
  parseJSON value = FlatEntity `fmap` parseJSON value                             
