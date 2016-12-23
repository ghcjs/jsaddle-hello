module Main ( main ) where

import qualified JSaddleHello (main)
import Language.Javascript.JSaddle.WKWebView (run)

main = run JSaddleHello.main
