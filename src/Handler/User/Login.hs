{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.User.Login where

import Import
--import Network.HTTP.Types.Status

formLogin :: Form (Text, Text)
formLogin = renderBootstrap2 $ (,)
    <$> areq emailField "E-mail: " Nothing
    <*> areq passwordField "Senha: " Nothing

getEntrarR :: Handler Html
getEntrarR = do 
    (widget,_) <- generateFormPost formLogin
    msg <- getMessage
    sess <- lookupSession "_EMAIL"
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        addStylesheet (StaticR css_login_css)
        $(whamletFile "templates/navbar.hamlet")
        [whamlet|
            <main>
                <div class="login-container">
                    $maybe mensa <- msg 
                        <div>
                            ^{mensa}
                    
                    <h1>
                        Entrar
                    
                    <form method=post action=@{EntrarR}>
                        ^{widget}
                        <input type="submit" value="Entrar" class="btn btn-dark mt-3">
                    
                    <a href=@{UserR} class="mt-3">
                        Quero me cadastrar
        |]

postEntrarR :: Handler Html
postEntrarR = do 
    ((result,_),_) <- runFormPost formLogin
    case result of 
        FormSuccess ("root@root.com", "root123") -> do 
            setSession "_EMAIL" "root@root.com"
            redirect AdminR
        FormSuccess (email, senha) -> do 
           user <- runDB $ getBy (UniqueEmail email) -- select * from user where email=digitado.email
           case user of
                Nothing -> do
                    setMessage [shamlet|
                        <div class="alert alert-danger">
                            E-mail não encontrado
                    |]
                    redirect EntrarR
                Just (Entity _ usu) -> do 
                    if (userSenha usu == senha) then do
                        -- lembra de quem está logado
                        setSession "_EMAIL" (userNome usu) -- (show uid) -- (userNome usu)
                        redirect HomeR
                    else do 
                        setMessage [shamlet|
                            <div class="alert alert-danger">
                                Senha incorreta
                        |]
                        redirect EntrarR 
        _ -> redirect HomeR

postSairR :: Handler Html 
postSairR = do 
    deleteSession "_EMAIL" -- "_NOME"
    redirect HomeR

getAdminR :: Handler Html
getAdminR = do 
    defaultLayout [whamlet|
        <h1>
            BEM-VINDO MEU REI!

    |]
