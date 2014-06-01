module Handler.StoriesStoryNotes where

import Import
import qualified Authorization as Auth
import GHC.Generics

data NotesValue = NotesValue { notes :: [Text]
                             } deriving (Eq, Show, Generic)

instance FromJSON NotesValue

putStoriesStoryNotesR :: ProjectId -> StoryId -> Handler ()
putStoriesStoryNotesR projectId storyId = do
  Auth.assert $ Auth.memberOfProject projectId
  (NotesValue newNotes) <- requireJsonBody
  runDB $ do
    storyMby <- selectFirst [StoryId ==. storyId, StoryProject ==. projectId] []
    case storyMby of
        Nothing -> notFound
        Just _ -> update storyId [StoryNotes =. newNotes]
