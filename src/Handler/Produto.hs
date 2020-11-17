{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Produto where

import Import

-- gera html das caixax de form text
formProduto :: Form Produto
formProduto = renderDivs $ Produto
    <$> areq textField (FieldSettings "Nome: "
                            (Just "nome do produto") 
                            (Just "hs1") Nothing
                            [("class", "classe1")]
                        ) Nothing
    <*> areq doubleField "Preço: " Nothing

getProdutoR :: Handler Html
getProdutoR = do
    (widget, _) <- generateFormPost formProduto
    defaultLayout [whamlet|
        <form action=@{ProdutoR} method=post>
            ^{widget}
            <input type="submit" value="Cadastrar">
    |]

postProdutoR :: Handler Html
postProdutoR = do
    ((res, _), _) <- runFormPost formProduto
    case res of
        FormSuccess produto -> do
            pid <- runDB (insert produto)
            redirect (DescR pid)
        _ -> redirect HomeR

-- select * from produto where id - pid
getDescR :: ProdutoId -> Handler Html
getDescR pid = do
    produto <- runDB $ get404 pid
    defaultLayout [whamlet|
        <h1>
            Nome: #{produtoNome produto}
        <h2>
            Preço: #{produtoPreco produto}
    |]
