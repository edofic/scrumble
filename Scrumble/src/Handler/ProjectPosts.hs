module Handler.ProjectPosts where

import Import
import qualified Authorization as Auth
import Data.Maybe (isJust)
import Validation

getProjectPostsR :: ProjectId -> Handler Value
getProjectPostsR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  runDB $ do
    posts <- selectList [ProjectPostProject ==. projectId] []
    infused <- sequence $ fmap infuseCommentsAndUser posts
    return $ array $ infused
  where 
        infuseCommentsAndUser post = do
          comments <- selectList [ProjectPostCommentPost ==. (entityKey post)] []
          infusedComments <- sequence $ fmap infuseCommentsUser comments
          let jsonComments = array $ infusedComments
          userEntity <- selectFirst [UserId ==. (projectPostUserId $ entityVal post)] []
          let userJson = maybe (Null) (toJSON . FlatEntity) userEntity
          return $ toJSONWith post (toJSON . FlatEntity) [("comments", jsonComments), ("user", userJson)]

        infuseCommentsUser comment = do
          userEntity <- selectFirst [UserId ==. (projectPostCommentUserId $ entityVal comment)] []
          let userJson = maybe (Null) (toJSON . FlatEntity) userEntity
          return $ toJSONWith comment (toJSON . FlatEntity) [("user", userJson)]


postProjectPostsR :: ProjectId -> Handler Value
postProjectPostsR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  currentTime :: Integer <- liftIO $ currentTimestamp
  user <- Auth.currentUser
  post :: ProjectPost <- requireJsonBodyWith [("project", toJSON projectId), ("userId", toJSON $ entityKey user), ("date", toJSON currentTime)]
  _ <- runDB $ insert post
  getProjectPostsR projectId


postProjectPostsCommentsR :: ProjectId -> ProjectPostId -> Handler Value
postProjectPostsCommentsR projectId postId = do
  Auth.assert $ Auth.memberOfProject projectId
  currentTime :: Integer <- liftIO $ currentTimestamp
  user <- Auth.currentUser
  comment :: ProjectPostComment <- requireJsonBodyWith [("userId", toJSON $ entityKey user), ("post", toJSON postId), ("date", toJSON currentTime)]
  _ <- runDB $ do
    post <- selectFirst [ProjectPostId ==. postId, ProjectPostProject ==. projectId] []
    runValidationHandler $ do
      ("projectId", "Post should be a part of the project refered by projectId in the path.") `validate` (isJust post)
    insert comment
  getProjectPostsR projectId



