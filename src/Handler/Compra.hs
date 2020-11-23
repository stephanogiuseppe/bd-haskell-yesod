{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Compra where

import Import
import Tools
import Database.Persist.Sql

getListCompraR :: Handler Html
getListCompraR = do
    sess <- lookupSession "_EMAIL"
    case sess of
        Nothing -> redirect HomeR
        Just email -> do
            usu <- runDB $ getBy (UniqueEmail email)
            case usu of
                Nothing -> redirect HomeR
                Just (Entity uid user) -> do
                    let sql = "SELECT ??,??,?? FROM user \
                        \ INNER JOIN compra ON compra.userid = user.id \
                        \ INNER JOIN produto ON compra.produtoid = produto.id \
                        \ WHERE user.id = ?"
                    produtos <- runDB $ rawSql sql [toPersistValue uid] :: Handler [(Entity User, Entity Compra, Entity Produto)]
                    defaultLayout $ do
                        [whamlet|
                            <h1>
                                COMPRAS de #{userNome user}

                            <ul>
                                $forall (Entity _ _, Entity _ compra, Entity _ produto) <- produtos
                                    <li>
                                        #{produtoNome produto} : #{produtoPreco produto * (fromIntegral (compraQtunit compra))}
                        |]

postCompraR :: ProdutoId -> Handler Html
postCompraR pid = do
    ((resp, _), _) <- runFormPost formQt
    case resp of
        FormSuccess qt -> do
            sess <- lookupSession "_EMAIL"
            case sess of
                Nothing -> redirect HomeR
                Just email -> do
                    user <- runDB $ getBy (UniqueEmail email)
                    case user of
                        Nothing -> redirect HomeR
                        Just (Entity uid _) -> do
                            _ <- runDB $ insert (Compra uid pid qt)
                            redirect ListCompraR
        _ -> redirect HomeR