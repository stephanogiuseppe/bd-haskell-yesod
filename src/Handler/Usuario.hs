{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Usuario where

import Import
import Text.Lucius

formUsu :: Form (Usuario, Text) 
formUsu = renderBootstrap2 $ (,) 
    <$> (Usuario 
        <$> areq textField "Nome: " Nothing
        <*> areq emailField "E-mail: " Nothing
        <*> areq passwordField "Senha: " Nothing)
    <*> areq passwordField "Digite Novamente: " Nothing

getUsuarioR :: Handler Html
getUsuarioR = do 
    (widget, _) <- generateFormPost formUsu
    msg <- getMessage
    defaultLayout $ do 
        toWidgetHead $(luciusFile "templates/form.lucius")
        $(whamletFile "templates/form.hamlet")

postUsuarioR :: Handler Html
postUsuarioR = do 
    ((result,_),_) <- runFormPost formUsu
    case result of 
        FormSuccess (usuario, userVerlidation) -> do 
            if (usuarioSenha usuario == userVerlidation) then do 
                _ <- runDB $ insert usuario 
                setSession "_EMAIL" (usuarioNome usuario)
                setMessage [shamlet|
                    <div>
                        USUARIO INCLUIDO
                |]
                redirect UsuarioR
            else do 
                setMessage [shamlet|
                    <div>
                        SENHA E VERIFICACAO N CONFEREM
                |]
                redirect UsuarioR
        _ -> redirect HomeR


