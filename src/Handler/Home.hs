{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Home where

import Import

-- <img src=@{staticR img_big_pot_witch_class_jpg}>
getHomeR :: Handler Html
getHomeR = do
    defaultLayout $ do
        sess <- lookupSession "_EMAIL"
        addStylesheet (StaticR css_bootstrap_css)
        toWidgetHead [lucius|
            h1 {
                color : red;
            }
            
            ul {
                display: inline;
                list-style: none;
            }
        |]
        [whamlet|
            <h1>
                Sistema de Produtos
            <ul>
                <li>
                    <a href=@{ProdutoR}>
                        Cadastro de Produtos
                <li>
                    <a href=@{ListaR}>
                        Listagem de Produtos

                $maybe email <- sess
                    <li>
                        <div>
                            Olá #{email}
                            <form action=@{SairR} method=post>
                                <input type="submit" value="sair">
                $nothing
                    <li>
                        <a href=@{EntrarR}>
                            Entra
        |]
