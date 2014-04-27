module Handler.SprintStories where

import Import
import qualified Authorization as Auth

getSprintStoriesR :: ProjectId -> SprintId -> Handler Value
getSprintStoriesR projectId sprintId = do
  Auth.assert $ Auth.memberOfProject projectId
  stories <- runDB $ selectList [StoryProject ==. projectId, StorySprint ==. Just sprintId] []
  return $ array $ FlatEntity `map` stories
