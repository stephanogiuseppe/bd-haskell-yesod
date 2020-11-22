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
        addStylesheet (StaticR css_home_css)
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
            <nav>
                <div class="nav-santos">
                    <div class="nav-santos-items">
                        <a href=@{HomeR}>
                            <img src=@{StaticR img_santos_fc_png} class="nav-icon">

                        <ul class="navbar-nav mr-auto mt-2 mt-lg-0 ml-4">
                            <li class="nav-item">
                                <a class="nav-link" href=@{HomeR}>
                                    Home
                            <li class="nav-item">
                                <a class="nav-link" href=@{ProdutoR}>
                                    Cadastro de Produtos
                            <li class="nav-item">
                                <a class="nav-link" href=@{ListaR}>
                                    Listagem de Produtos

                    $maybe email <- sess
                        <div class="text-secondary mr-3">
                            #{email}
                        <form action=@{SairR} method=post class="form-inline">
                            <button class="btn btn-light" type="submit">
                                Sair
                    $nothing
                        <a href=@{EntrarR} class="btn btn-light">
                            Entrar
        |]
