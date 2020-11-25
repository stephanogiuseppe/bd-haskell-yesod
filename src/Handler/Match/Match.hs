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
    <*> areq textField "Descrição: " (fmap matchDescription match)
    <*> areq intField "Gols do Santos: " (fmap matchGoalsHome match)
    <*> areq intField "Gols do rival: " (fmap matchGoalsAway match)
    <*> areq (selectField getAllPlayers) "Melhor Jogador: " (fmap matchBestPlayer match)








getAllPlayers = do
    rows <- runDB $ selectList [] [Asc PlayerName]
    optionsPairs $
        map (\r -> (playerName $ entityVal r, entityKey r)) rows

getAllMatches = do
    rows <- runDB $ selectList [] [Asc MatchRival]
    optionsPairs $
        map (\r -> (matchRival $ entityVal r, entityKey r)) rows

-- renderDivs
formPlayerMatch :: Form PlayerMatch 
formPlayerMatch = renderBootstrap $ PlayerMatch
    <$> areq (selectField getAllPlayers) "Jogador: " Nothing
    <*> areq (selectField getAllMatches) "Partida: " Nothing

getPlayerMatchR :: Handler Html
getPlayerMatchR = do 
    (widget,_) <- generateFormPost formPlayerMatch
    msg <- getMessage
    defaultLayout $ 
        [whamlet|
            $maybe mensa <- msg 
                <div>
                    ^{mensa}
            
            <h1>
                Cadastro de jogadores em partidas
            
            <form method=post action=@{PlayerMatchR}>
                ^{widget}
                <input type="submit" value="Cadastrar">
        |]

postPlayerMatchR :: Handler Html
postPlayerMatchR = do 
    ((result,_),_) <- runFormPost formPlayerMatch
    case result of 
        FormSuccess playerMatch -> do 
            runDB $ insert playerMatch 
            setMessage [shamlet|
                <div>
                    Jogador incluído
            |]
            redirect PlayerMatchR
        _ -> redirect HomeR






















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
                        <h1>
                            Rival: #{matchRival match} - Data: #{show $ matchDate match}
                        <div>
                            Gols do Santos Futebol Clube: #{matchGoalsAway match}
                        <div>
                            Gols do #{matchRival match}: #{matchGoalsAway match}

                <div>
                    <a href=@{MatchesR} class="btn btn-info mt-3">
                        Voltar
        |]

-- Delete Match
postMatchDeleteR :: MatchId -> Handler Html
postMatchDeleteR pid = do
    runDB $ delete pid
    redirect MatchesR
