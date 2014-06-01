module Handler.ProjectPosts where

import Import
import qualified Authorization as Auth
import Data.Maybe (isJust)
import Validation
import Model.ProjectRole

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


postProjectPostsR :: ProjectId -> Handler ()
postProjectPostsR projectId = do
  Auth.assert $ Auth.memberOfProject projectId
  currentTime :: Integer <- liftIO $ currentTimestamp
  user <- Auth.currentUser
  post :: ProjectPost <- requireJsonBodyWith [("project", toJSON projectId), ("userId", toJSON $ entityKey user), ("date", toJSON currentTime)]
  _ <- runDB $ insert post
  return ()


postProjectPostsCommentsR :: ProjectId -> ProjectPostId -> Handler ()
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
  return ()

deleteProjectPostsPostR :: ProjectId -> ProjectPostId -> Handler ()
deleteProjectPostsPostR projectId postId = do
  Auth.assert $ Auth.roleOnProject ScrumMaster projectId
  _ <- runDB $ do
    post <- selectFirst [ProjectPostId ==. postId, ProjectPostProject ==. projectId] []
    runValidationHandler $ do
      ("projectId", "Post should be a part of the project refered by projectId in the path.") `validate` (isJust post)
    deleteWhere $ [ProjectPostCommentPost ==. postId] 
    deleteWhere $ [ProjectPostId ==. postId, ProjectPostProject ==. projectId]
  return ()


deleteProjectPostsCommentR :: ProjectId -> ProjectPostId -> ProjectPostCommentId -> Handler ()
deleteProjectPostsCommentR projectId postId commentId = do
  Auth.assert $ Auth.roleOnProject ScrumMaster projectId
  _ <- runDB $ do
    post <- selectFirst [ProjectPostId ==. postId, ProjectPostProject ==. projectId] []
    runValidationHandler $ do
      ("projectId", "Post should be a part of the project refered by projectId in the path.") `validate` (isJust post)
    deleteWhere $ [ProjectPostCommentId ==. commentId] 
  return ()
