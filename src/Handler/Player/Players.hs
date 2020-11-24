{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Player.Players where

import Import

getPlayersR :: Handler Html
getPlayersR = do
    players <- runDB $ selectList [] [Asc PlayerNumber]
    defaultLayout $ do
        sess <- lookupSession "_EMAIL"
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        addStylesheet (StaticR css_home_css)
        $(whamletFile "templates/navbar.hamlet")
        $(whamletFile "templates/player/players.hamlet")