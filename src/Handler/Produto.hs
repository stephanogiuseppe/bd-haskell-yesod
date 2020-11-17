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
postProdutoR = undefined
