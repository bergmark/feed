--------------------------------------------------------------------
-- |
-- Module    : Text.Atom.Pub.Export
-- Copyright : (c) Galois, Inc. 2008,
--             (c) Sigbjorn Finne 2009-
-- License   : BSD3
--
-- Maintainer: Sigbjorn Finne <sof@forkIO.com>
-- Stability : provisional
-- Portability:: portable
-- Description: Serializing APP types (as XML.)
--
-- Serializing Atom Publishing Protocol types as XML.
--
--------------------------------------------------------------------
module Text.Atom.Pub.Export
  ( mkQName
  , mkElem
  , mkLeaf
  , mkAttr
  , xmlns_app
  , appNS
  , xmlService
  , xmlWorkspace
  , xmlCollection
  , xmlCategories
  , xmlAccept
  ) where

import Prelude.Compat

import Data.Text (Text)
import Data.XML.Compat
import Data.XML.Types
import Text.Atom.Feed.Export (mb, xmlCategory, xmlTitle, xmlns_atom)
import Text.Atom.Pub

-- ToDo: old crud; inline away.
mkQName :: Maybe Text -> Text -> Name
mkQName a b = Name b a Nothing

mkElem :: Name -> [Attr] -> [Element] -> Element
mkElem a b c = Element a b $ map NodeElement c

mkLeaf :: Name -> [Attr] -> Text -> Element
mkLeaf a b c = Element a b [NodeContent $ ContentText c]

xmlns_app :: Attr
xmlns_app = (mkQName (Just "xmlns") "app", [ContentText appNS])

appNS :: Text
appNS = "http://purl.org/atom/app#"

appName :: Text -> Name
appName nc = (mkQName (Just "app") nc) {nameNamespace = Just appNS}

xmlService :: Service -> Element
xmlService s =
  mkElem
    (appName "service")
    [xmlns_app, xmlns_atom]
    (map xmlWorkspace (serviceWorkspaces s) ++ serviceOther s)

xmlWorkspace :: Workspace -> Element
xmlWorkspace w =
  mkElem
    (appName "workspace")
    [mkAttr "xml:lang" "en"]
    (concat [[xmlTitle (workspaceTitle w)], map xmlCollection (workspaceCols w), workspaceOther w])

xmlCollection :: Collection -> Element
xmlCollection c =
  mkElem
    (appName "collection")
    [mkAttr "href" (collectionURI c)]
    (concat
       [ [xmlTitle (collectionTitle c)]
       , map xmlAccept (collectionAccept c)
       , map xmlCategories (collectionCats c)
       , collectionOther c
       ])

xmlCategories :: Categories -> Element
xmlCategories (CategoriesExternal u) = mkElem (appName "categories") [mkAttr "href" u] []
xmlCategories (Categories mbFixed mbScheme cs) =
  mkElem
    (appName "categories")
    (mb
       (\f ->
          mkAttr
            "fixed"
            (if f
               then "yes"
               else "no"))
       mbFixed ++
     mb (mkAttr "scheme") mbScheme)
    (map xmlCategory cs)

xmlAccept :: Accept -> Element
xmlAccept a = mkLeaf (appName "accept") [] (acceptType a)
