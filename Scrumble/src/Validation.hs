module Validation 
( validate
, validateM
, runValidation
, runValidationHandler
)where

import Import
import Control.Monad.Writer
import Network.HTTP.Types.Status (badRequest400)

validate :: MonadWriter [(Text, Text)] m => (Text, Text) -> Bool -> m ()
validate err p = when (not p) $ tell [err]

validateM :: MonadWriter [(Text, Text)] m => (Text, Text) -> m Bool -> m ()
validateM err pm = do
  p <- pm
  when (not p) $ tell [err]

runValidation :: (Eq w, Functor m, Monoid w) => WriterT w m a -> m (Maybe w)
runValidation = fmap (mfilter (/= mempty) . Just . snd) . runWriterT

runValidationHandler :: (Eq a, MonadHandler m, ToJSON a) => WriterT [(Text, a)] m t -> m ()
runValidationHandler validation = do
  errs <- merrs
  maybe (return ()) sendErrors errs
  where
    merrs = runValidation validation
    sendErrors = sendResponseStatus badRequest400 . render
    render = object . map (\(k,m) -> (k, toJSON m)) 
