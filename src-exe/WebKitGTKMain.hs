module Main ( main ) where

import qualified JSaddleHello (main)
import Language.Javascript.JSaddle.WebKitGTK (run)

main = run JSaddleHello.main
