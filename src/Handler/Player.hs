{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Player where

import Import
import Tools
import Text.Lucius
import Text.Julius
import Database.Persist.Sql (fromSqlKey)

--Player
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
    (widget, _) <- generateFormPost (formPlayer mp)
    defaultLayout [whamlet|
        <form action=@{rt} method=post>
            ^{widget}
            <input type="submit" value="Salvar">
    |]

formPlayer :: Maybe Player -> Form Player
formPlayer player = renderBootstrap $ Player
    <$> areq textField "Nome: " (fmap playerName player)
    <*> areq dayField "Data de nascimento: " (fmap playerYear player)
    <*> areq textField "Posição: " (fmap playerPosition player)
    <*> areq intField "Número: " (fmap playerNumber player)
    <*> areq textField "Descrição: " (fmap playerDescription player)

-- Players
getPlayersR :: Handler Html
getPlayersR = do
    players <- runDB $ selectList [] [Asc PlayerNumber]
    defaultLayout $ do
        sess <- lookupSession "_EMAIL"
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        addStylesheet (StaticR css_home_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div>
                    <a class="nav-link" href=@{PlayerR}>
                        Adicionar Jogador
                    
                <div>
                    <table class="table table-striped">
                        <thead class="thead-dark">
                            <tr>
                                <th>
                                    Número
                                <th>
                                    Nome
                                <th>
                                    Posição
                                <th>
                                    Nascimento
                                <th>
                                    Detalhes
                                <th>
                                <th>
                        <tbody>
                            $forall Entity pid player <- players
                                <tr>
                                    <td>
                                        #{playerNumber player}
                                    <td>
                                        <a href=@{PlayerEditR pid}>
                                            #{playerName player}
                                    <td>
                                        #{playerPosition player}
                                    <td>
                                        #{show $ playerYear player}
                                    <td>
                                        <a href=@{PlayerDescR pid}>
                                            Descrição
                                    <td>
                                        <a href=@{PlayerEditR pid}>
                                            Editar
                                    <td>
                                        <form action=@{PlayerDeleteR pid} method=post>
                                            <input type="submit" value="X">
    |]

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
    defaultLayout [whamlet|
        <h1>
            Nome: #{playerName player}
        <h2>
            Posição: #{playerPosition player}
    |]

-- Delete Player
postPlayerDeleteR :: PlayerId -> Handler Html
postPlayerDeleteR pid = do
    runDB $ delete pid
    redirect PlayersR



-- @TODO
-- Upload files (image)
player :: PlayerId -> FilePath
player playerId = "files/players/" </> (show . fromSqlKey $ playerId)

postUploadImageR :: PlayerId -> Handler Html
postUploadImageR = getUploadImageR

getUploadImageR :: PlayerId -> Handler Html
getUploadImageR playerId = do
    ((res, campos), enctype) <- runFormPost . renderDivs $
        areq fileField "Foto:" Nothing
    case res of
        FormSuccess fileRes -> do
            liftIO $ fileMove fileRes (player playerId)
            redirect $ PlayerDescR playerId
        FormFailure erros -> do
            setMessage
                [shamlet| $forall e <- erros
                    <p>Ocorreu um erro: #{e}
                |]
            redirect $ UploadImageR playerId
        FormMissing ->
            defaultLayout [whamlet|
                <form action=@{UploadImageR playerId} method="POST" enctype=#{enctype}>
                    ^{campos}
                    <button>
                        Enviar
            |]
