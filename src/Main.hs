module Main ( main ) where

import Control.Monad.IO.Class (MonadIO(..))
import Control.Concurrent.MVar (takeMVar, putMVar, newEmptyMVar)
import Control.Lens ((^.))
import Language.Javascript.JSaddle
       (run, jsg, js, js1, jss, fun, valToNumber, syncPoint)

main = run 3709 $ do
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

    -- In GHC compiled version the WebSocket connection will end when this
    -- thread ends.  So we will wait until the user clicks exit.
    liftIO $ takeMVar exitMVar
    doc ^. js "body" ^. jss "innerHTML" "<h1>Ka kite ano (See you later)</h1>"
    return ()



