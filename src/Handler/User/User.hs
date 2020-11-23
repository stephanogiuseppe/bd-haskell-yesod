{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.User.User where

import Import
import Text.Lucius

formUsu :: Form (User, Text) 
formUsu = renderBootstrap2 $ (,) 
    <$> (User 
        <$> areq textField "Nome: " Nothing
        <*> areq emailField "E-mail: " Nothing
        <*> areq passwordField "Senha: " Nothing)
    <*> areq passwordField "Digite Novamente: " Nothing

getUserR :: Handler Html
getUserR = do 
    (widget, _) <- generateFormPost formUsu
    msg <- getMessage
    sess <- lookupSession "_EMAIL"
    defaultLayout $ do
        addStylesheet (StaticR css_bootstrap_css)
        addStylesheet (StaticR css_common_css)
        addStylesheet (StaticR css_login_css)
        toWidgetHead $(luciusFile "templates/form.lucius")
        $(whamletFile "templates/navbar.hamlet")
        $(whamletFile "templates/form.hamlet")

postUserR :: Handler Html
postUserR = do 
    ((result,_),_) <- runFormPost formUsu
    case result of 
        FormSuccess (user, userVerlidation) -> do 
            if (userSenha user == userVerlidation) then do 
                _ <- runDB $ insert user 
                setSession "_EMAIL" (userNome user)
                setMessage [shamlet|
                    <div>
                        Usuário incluído
                |]
                redirect UserR
            else do 
                setMessage [shamlet|
                    <div>
                        SENHA E VERIFICACAO N CONFEREM
                |]
                redirect UserR
        _ -> redirect HomeR


