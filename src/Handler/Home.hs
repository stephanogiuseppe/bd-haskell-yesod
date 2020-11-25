{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Home where

import Import

getHomeR :: Handler Html
getHomeR = do
    defaultLayout $ do
        sess <- lookupSession "_EMAIL"
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        addStylesheet (StaticR css_home_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <section class="d-flex">
                    <div>
                        <img src=@{StaticR img_santos_fc_png} alt="Santos Futebol Clube" class="santosfc">
                    
                    <div class="section-right">
                        <h1 class="santos-title">
                            Santos Futebol Clube
                        
                        <h2>
                            Match Day
        |]
