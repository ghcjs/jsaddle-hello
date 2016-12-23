{-# LANGUAGE ScopedTypeVariables #-}
module JSaddleHello ( main ) where

import Data.Monoid ((<>))
import Control.Monad (forever)
import Control.Monad.IO.Class (MonadIO(..))
import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (takeMVar, putMVar, newEmptyMVar)
import Control.Lens ((^.))
import Language.Javascript.JSaddle
       (jsg, jsg3, js, js1, jss, fun, valToNumber, syncPoint,
        nextAnimationFrame, runJSM, askJSM, global)

main = do
    doc <- jsg "document"
    doc ^. js "body" ^. jss "innerHTML" "<h1>Kia ora (Hi)</h1>"

    -- Create a haskell function call back for the onclick event
    doc ^. jss "onclick" (fun $ \ _ _ [e] -> do
        x <- e ^. js "clientX" >>= valToNumber
        y <- e ^. js "clientY" >>= valToNumber
        newParagraph <- doc ^. js1 "createElement" "p"
        newParagraph ^. js1 "appendChild" (
            doc ^. js1 "createTextNode" ("Click " ++ show (x, y)))
        doc ^. js "body" ^. js1 "appendChild" newParagraph
        return ())

    -- Make an exit button
    exitMVar <- liftIO newEmptyMVar
    exit <- doc ^. js1 "createElement" "span"
    exit ^. js1 "appendChild" (
        doc ^. js1 "createTextNode" "Click here to exit")
    doc ^. js "body" ^. js1 "appendChild" exit
    exit ^. jss "onclick" (fun $ \ _ _ _ -> liftIO $ putMVar exitMVar ())

    -- Force all all the lazy evaluation to be executed
    syncPoint

    -- Animate the color of the exit button
    ctx <- askJSM
    liftIO . forkIO . forever $
        (`runJSM` ctx) . nextAnimationFrame $ \ t -> do
            let n = floor ((sin (3 * t) + 1) * 128)
                (h1, h2) = n `divMod` 16
                hexDigits = ['0'..'9'] <> ['A'..'F']
            exit ^. js "style" ^. jss "color" ("#0000" <> [hexDigits !! h1, hexDigits !! h2])
            return ()

    -- In GHC compiled version the WebSocket connection will end when this
    -- thread ends.  So we will wait until the user clicks exit.
    liftIO $ takeMVar exitMVar
    doc ^. js "body" ^. jss "innerHTML" "<h1>Ka kite ano (See you later)</h1>"
    return ()



