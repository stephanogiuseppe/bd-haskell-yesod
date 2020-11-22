{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Login where

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
    defaultLayout $ 
        [whamlet|
            $maybe mensa <- msg 
                <div>
                    ^{mensa}
            
            <h1>
                ENTRAR
            
            <form method=post action=@{EntrarR}>
                ^{widget}
                <input type="submit" value="Entrar">
        |]

postEntrarR :: Handler Html
postEntrarR = do 
    ((result,_),_) <- runFormPost formLogin
    case result of 
        FormSuccess ("root@root.com", "root123") -> do 
            setSession "_EMAIL" "root@root.com"
            redirect AdminR
        FormSuccess (email, senha) -> do 
           usuario <- runDB $ getBy (UniqueEmail email) -- select * from usuario where email=digitado.email
           case usuario of
                Nothing -> do
                    setMessage [shamlet|
                        <div class="alert alert-danger">
                            E-mail não encontrado
                    |]
                    redirect EntrarR
                Just (Entity _ usu) -> do 
                    if (usuarioSenha usu == senha) then do
                        -- lembra de quem está logado
                        setSession "_EMAIL" (usuarioNome usu) -- (show uid) -- (usuarioNome usu)
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
