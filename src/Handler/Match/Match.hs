{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Match.Match where

import Import
import Database.Persist.Postgresql

-- Render Match Form
getMatchR :: Handler Html
getMatchR = renderMatchForm MatchR Nothing

postMatchR :: Handler Html
postMatchR = do
    ((res, _), _) <- runFormPost (formMatch Nothing)
    case res of
        FormSuccess match -> do
            pid <- runDB (insert match)
            redirect (MatchDescR pid)
        _ -> redirect HomeR

renderMatchForm :: Route App -> Maybe Match -> Handler Html
renderMatchForm rt mp = do
    sess <- lookupSession "_EMAIL"
    (widget, _) <- generateFormPost (formMatch mp)
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div class="santos-title">
                    <h1>
                        Cadasto de Partida
                    
                <div>
                    <form action=@{rt} method=post>
                        ^{widget}
                        <input type="submit" value="Salvar" class="btn btn-success mt-3">

                    <a href=@{MatchesR} class="btn btn-info mt-3">
                        Voltar
        |]

-- Create form Match
formMatch :: Maybe Match -> Form Match
formMatch match = renderBootstrap $ Match
    <$> areq textField "Rival: " (fmap matchRival match)
    <*> areq textField "Campeonato: " (fmap matchLeague match)
    <*> areq dayField "Data do jogo: " (fmap matchDate match)
    <*> areq textField "Local da partida: " (fmap matchPlace match)
    <*> aopt textareaField "Descrição: " (matchDescription <$> match)
    <*> aopt intField "Gols do Santos: " (matchGoalsSantos <$> match)
    <*> aopt intField "Gols do rival: " (matchGoalsAway <$> match)
    <*> aopt (selectField getAllPlayers) "Melhor Jogador do Santos: " (matchBestPlayer <$> match)

-- Aux
getAllPlayers = do
    rows <- runDB $ selectList [] [Asc PlayerName]
    optionsPairs $
        map (\r -> (playerName $ entityVal r, entityKey r)) rows

-- Edit Match
getMatchEditR :: MatchId -> Handler Html
getMatchEditR pid = do
    err <- runDB $ get404 pid
    renderMatchForm (MatchEditR pid) (Just err)

postMatchEditR :: MatchId -> Handler Html
postMatchEditR pid = do
    ((res, _), _) <- runFormPost (formMatch Nothing)
    case res of
        FormSuccess novo -> do
            _ <- runDB (replace pid novo)
            redirect MatchesR
        _ -> redirect HomeR

-- Match Description
getMatchDescR :: MatchId -> Handler Html
getMatchDescR pid = do
    match <- runDB $ get404 pid
    sess <- lookupSession "_EMAIL"
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div class="santos-title">
                    <div>
                        <h2>
                            Rival: #{matchRival match} - Data: #{show $ matchDate match}
                        <div>
                            $maybe goalsSantos <- matchGoalsSantos match
                                Gols do Santos Futebol Clube: #{goalsSantos}
                        <div>
                            $maybe goalsAway <- matchGoalsAway match
                                Gols do #{matchRival match}: #{goalsAway}
                        <div>
                            $maybe description <- matchDescription match
                                Detalhes da partida: #{description}

                <div>
                    <a href=@{MatchesR} class="btn btn-info mt-3">
                        Voltar
        |]

-- Delete Match
postMatchDeleteR :: MatchId -> Handler Html
postMatchDeleteR pid = do
    runDB $ delete pid
    redirect MatchesR
