{-# LANGUAGE RankNTypes #-}

module Validation 
( validate
, validateM
, runValidation
, runValidationHandler
, Validation
, ValidationField
)where

import Import
import Control.Monad.Writer
import Network.HTTP.Types.Status (badRequest400) 

type ValidationField = (Text, Text)
type Validation m a = MonadWriter [ValidationField] m => a -> m ()

validate :: ValidationField -> Validation m Bool
validate err p = when (not p) $ tell [err]

validateM :: ValidationField -> Validation m (m Bool)
validateM err pm = do
  p <- pm
  when (not p) $ tell [err]

runValidation :: (Eq w, Functor m, Monoid w) => WriterT w m a -> m (Maybe w)
runValidation = fmap (mfilter (/= mempty) . Just . snd) . runWriterT

runValidationHandler :: (MonadHandler m) => WriterT [(Text, Text)] m t -> m t
runValidationHandler validation = do 
  (t, errs) <- runWriterT validation
  if errs /= mempty 
    then sendErrors errs
    else return t
  where
    sendErrors = sendResponseStatus badRequest400 . render
    render = object . map (\(k,m) -> (k, toJSON m)) 
