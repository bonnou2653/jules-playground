module Main where

-- NOTE: PureScriptでは、数値演算や文字列結合などの基本的な関数や型クラスの多くが `Prelude` モジュールに定義されています。
-- ほとんどのファイルにおいて、これらの基本機能を使用するために `import Prelude` が必要となります。
import Prelude

import Effect (Effect)
import Effect.Console (log)

main :: Effect Unit
main = do
  log "Hello World"
