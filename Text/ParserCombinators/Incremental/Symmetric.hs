{- 
    Copyright 2010-2015 Mario Blazevic

    This file is part of the Streaming Component Combinators (SCC) project.

    The SCC project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
    version.

    SCC is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with SCC.  If not, see
    <http://www.gnu.org/licenses/>.
-}

-- | This module defines parsing combinators for incremental parsers with symmetric choice.
-- 
-- The exported 'Parser' type can provide partial parsing results from partial input, as long as the output is a
-- 'Monoid'. Construct a parser using the primitives and combinators, supply it with input using functions 'feed' and
-- 'feedEof', and extract the parsed output using 'results'.
-- 
-- Implementation is based on Brzozowski derivatives.

{-# LANGUAGE EmptyDataDecls, FlexibleInstances #-}

module Text.ParserCombinators.Incremental.Symmetric (
   module Text.ParserCombinators.Incremental,
   Parser, Symmetric, allOf
)
where

import Control.Applicative (Alternative (empty, (<|>)), many, some)
import Control.Monad (MonadPlus (mzero, mplus))
import Data.Monoid (Monoid)

import Text.ParserCombinators.Incremental hiding (Parser)
import qualified Text.ParserCombinators.Incremental as Incremental (Parser)

-- | An empty type to specialize 'Parser' for the symmetric 'Alternative' instance.
data Symmetric

type Parser s r = Incremental.Parser Symmetric s r

-- | The symmetric version of the '<|>' choice combinator.
instance Monoid s => Alternative (Incremental.Parser Symmetric s) where
   empty = failure
   p1 <|> p2 = p1 <||> p2
   many = defaultMany
   some = defaultSome

-- | The 'MonadPlus' instances are the same as the 'Alternative' instances.
instance Monoid s => MonadPlus (Incremental.Parser Symmetric s) where
   mzero = failure
   mplus = (<|>)

allOf :: Parser s r -> Incremental.Parser a s r
allOf p = mapType allOf p
