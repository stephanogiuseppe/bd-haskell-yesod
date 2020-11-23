{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Player.PlayerFile where

import Import
import Tools
import Database.Persist.Sql (fromSqlKey)

-- @TODO
-- Upload files (image)
player :: PlayerId -> FilePath
player playerId = "files/players/" </> (show . fromSqlKey $ playerId)

postUploadImageR :: PlayerId -> Handler Html
postUploadImageR = getUploadImageR

getUploadImageR :: PlayerId -> Handler Html
getUploadImageR playerId = do
    ((res, campos), enctype) <- runFormPost . renderDivs $
        areq fileField "Foto: " Nothing
    case res of
        FormSuccess fileRes -> do
            liftIO $ fileMove fileRes (player playerId)
            redirect $ PlayerDescR playerId
        FormFailure erros -> do
            setMessage
                [shamlet| $forall e <- erros
                    <p>Ocorreu um erro: #{e}
                |]
            redirect $ UploadImageR playerId
        FormMissing ->
            defaultLayout [whamlet|
                <form action=@{UploadImageR playerId} method="POST" enctype=#{enctype}>
                    ^{campos}
                    <button>
                        Enviar
            |]
