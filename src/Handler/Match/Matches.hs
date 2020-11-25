{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Match.Matches where

import Import

getMatchesR :: Handler Html
getMatchesR = do
    matches <- runDB $ selectList [] [Asc MatchDate]
    defaultLayout $ do
        sess <- lookupSession "_EMAIL"
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        $(whamletFile "templates/navbar.hamlet")
        $(whamletFile "templates/match/matches.hamlet")