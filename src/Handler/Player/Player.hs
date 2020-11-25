{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Player.Player where

import Import

-- Render Player Form
getPlayerR :: Handler Html
getPlayerR = renderPlayerForm PlayerR Nothing

postPlayerR :: Handler Html
postPlayerR = do
    ((res, _), _) <- runFormPost (formPlayer Nothing)
    case res of
        FormSuccess player -> do
            pid <- runDB (insert player)
            redirect (PlayerDescR pid)
        _ -> redirect HomeR

renderPlayerForm :: Route App -> Maybe Player -> Handler Html
renderPlayerForm rt mp = do
    sess <- lookupSession "_EMAIL"
    (widget, _) <- generateFormPost (formPlayer mp)
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div class="santos-title">
                    <h1>
                        Cadasto de Jogador
                    
                <div>
                    <form action=@{rt} method=post>
                        ^{widget}
                        <input type="submit" value="Salvar" class="btn btn-success mt-3">

                    <a href=@{PlayersR} class="btn btn-info mt-3">
                        Voltar
        |]

formPlayer :: Maybe Player -> Form Player
formPlayer player = renderBootstrap $ Player
    <$> areq textField "Nome: " (fmap playerName player)
    <*> areq dayField "Data de nascimento: " (fmap playerYear player)
    <*> areq textField "Posição: " (fmap playerPosition player)
    <*> areq intField "Número: " (fmap playerNumber player)
    <*> areq textField "Descrição: " (fmap playerDescription player)

-- Edit Player
getPlayerEditR :: PlayerId -> Handler Html
getPlayerEditR pid = do
    err <- runDB $ get404 pid
    renderPlayerForm (PlayerEditR pid) (Just err)

postPlayerEditR :: PlayerId -> Handler Html
postPlayerEditR pid = do
    ((res, _), _) <- runFormPost (formPlayer Nothing)
    case res of
        FormSuccess novo -> do
            _ <- runDB (replace pid novo)
            redirect PlayersR
        _ -> redirect HomeR

-- Player Description
getPlayerDescR :: PlayerId -> Handler Html
getPlayerDescR pid = do
    player <- runDB $ get404 pid
    sess <- lookupSession "_EMAIL"
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div>
                    <div class="mt-3">
                        <h2>
                            Nome: #{playerName player}
                        <div>
                            Posição: #{playerPosition player}
                        <div>
                            Detalhes do jogador: #{playerDescription player}
                <div>
                    <a href=@{PlayersR} class="btn btn-info mt-3">
                        Voltar
        |]

-- Delete Player
postPlayerDeleteR :: PlayerId -> Handler Html
postPlayerDeleteR pid = do
    runDB $ delete pid
    redirect PlayersR
