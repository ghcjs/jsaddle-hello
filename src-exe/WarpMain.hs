module Main ( main ) where

import qualified JSaddleHello (main)
import Language.Javascript.JSaddle.Warp (run)

main = run 3709 JSaddleHello.main
