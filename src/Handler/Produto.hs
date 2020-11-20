{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Produto where

import Import
import Tools

-- gera html das caixax de form text
formProduto :: Maybe Produto -> Form Produto
formProduto mp = renderDivs $ Produto
    <$> areq textField (FieldSettings "Nome: "
                            Nothing
                            (Just "hs1") Nothing
                            [("class", "classe1")]
                        ) (fmap produtoNome mp)
    <*> areq doubleField "Preço: " (fmap produtoPreco mp)

auxProduto :: Route App -> Maybe Produto -> Handler Html
auxProduto rt mp = do
    (widget, _) <- generateFormPost (formProduto mp)
    defaultLayout [whamlet|
        <form action=@{rt} method=post>
            ^{widget}
            <input type="submit" value="Cadastrar">
    |]

getProdutoR :: Handler Html
getProdutoR = auxProduto ProdutoR Nothing
    

postProdutoR :: Handler Html
postProdutoR = do
    ((res, _), _) <- runFormPost (formProduto Nothing)
    case res of
        FormSuccess produto -> do
            pid <- runDB (insert produto)
            redirect (DescR pid)
        _ -> redirect HomeR

-- select * from produto where id - pid
getDescR :: ProdutoId -> Handler Html
getDescR pid = do
    produto <- runDB $ get404 pid
    (widget, _) <- generateFormPost formQt
    defaultLayout [whamlet|
        <h1>
            Nome: #{produtoNome produto}
        <h2>
            Preço: #{produtoPreco produto}
        
        <form action=@{CompraR pid} method=post>
            ^{widget}
            <input type="submit" value="Adicionar ao carrinho">
    |]

-- select * from produto order by preco desc
getListaR :: Handler Html
getListaR = do
    -- produtos :: [Entity ProdutoId Produto]
    produtos <- runDB $ selectList [] [Desc ProdutoPreco]
    defaultLayout [whamlet|
        <table>
            <thead>
                <tr>
                    <th>
                        Nome
                    <th>
                        Preco
                    <th>
                    <th>
            <tbody>
                $forall Entity pid produto <- produtos
                    <tr>
                        <td>
                            <a href=@{DescR pid}>
                                #{produtoNome produto}
                        <td>
                            #{produtoPreco produto}
                        <td>
                            <a href=@{UpdateProdutoR pid}>
                                Editar
                        <td>
                            <form action=@{DeleteProdutoR pid} method=post>
                                <input type="submit" value="X">
    |]

getUpdateProdutoR :: ProdutoId -> Handler Html
getUpdateProdutoR pid = do
    antigo <- runDB $ get404 pid
    auxProduto (UpdateProdutoR pid) (Just antigo)

-- update from produto where id = pid set ...
postUpdateProdutoR :: ProdutoId -> Handler Html
postUpdateProdutoR pid = do
    ((res, _), _) <- runFormPost (formProduto Nothing)
    case res of
        FormSuccess novo -> do
            _ <- runDB (replace pid novo)
            redirect ListaR
        _ -> redirect HomeR

-- delete from produto where id = pid
postDeleteProdutoR :: ProdutoId -> Handler Html
postDeleteProdutoR pid = do
    runDB $ delete pid
    redirect ListaR
