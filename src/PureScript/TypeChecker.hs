-----------------------------------------------------------------------------
--
-- Module      :  PureScript.TypeChecker
-- Copyright   :  (c) Phil Freeman 2013
-- License     :  MIT
--
-- Maintainer  :  Phil Freeman <paf31@cantab.net>
-- Stability   :  experimental
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances #-}

module PureScript.TypeChecker (
    module PureScript.TypeChecker.Monad,
    module PureScript.TypeChecker.Kinds,
    module PureScript.TypeChecker.Types,
    typeCheck,
    typeCheckAll,
) where

import PureScript.TypeChecker.Monad
import PureScript.TypeChecker.Kinds
import PureScript.TypeChecker.Types

import Data.List
import Data.Maybe
import Data.Function

import PureScript.Values
import PureScript.Types
import PureScript.Kinds
import PureScript.Declarations

import Control.Monad.State
import Control.Monad.Error

import qualified Data.Map as M

typeCheck :: Declaration -> Check ()
typeCheck (DataDeclaration dcs@(DataConstructors
  { typeConstructorName = name
  , typeArguments = args
  , dataConstructors = ctors
  })) = rethrow (("Error in type constructor " ++ name ++ ": ") ++) $ do
  env <- getEnv
  guardWith (name ++ " is already defined") $ not $ M.member name (types env)
  ctorKind <- kindsOf name args (catMaybes $ map snd ctors)
  putEnv $ env { types = M.insert name ctorKind (types env) }
  flip mapM_ ctors $ \(dctor, maybeTy) ->
    rethrow (("Error in data constructor " ++ name ++ ": ") ++) $ do
      env' <- getEnv
      guardWith (dctor ++ " is already defined") $ not $ flip M.member (names env') dctor
      let retTy = foldl TypeApp (TypeConstructor name) (map TypeVar args)
      let dctorTy = maybe retTy (\ty -> Function [ty] retTy) maybeTy
      putEnv $ env' { names = M.insert dctor dctorTy (names env') }
typeCheck (ValueDeclaration name val) = rethrow (("Error in declaration " ++ name ++ ": ") ++) $ do
  env <- getEnv
  case M.lookup name (names env) of
    Just ty -> throwError $ name ++ " is already defined"
    Nothing -> do
      ty <- typeOf name val
      putEnv (env { names = M.insert name ty (names env) })

typeCheckAll :: [Declaration] -> Check ()
typeCheckAll = mapM_ typeCheck
