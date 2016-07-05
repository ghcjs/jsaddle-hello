module Main (
    main
) where

import GHCJS.DOM (runWebGUI, postGUIAsync)
import Control.Lens ((^.))
import Language.Javascript.JSaddle (jsg, js, jss, runJSaddle)

main = runWebGUI $ \ webView -> do
    let runjs = postGUIAsync . runJSaddle webView
    runjs $ do
        document <- jsg "document"
        let body = js "body"
            setInnerHTML = jss "innerHTML"
        document ^. body ^. setInnerHTML "<h1>Hello World</h1>"
