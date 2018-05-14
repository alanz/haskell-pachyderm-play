module Main where

import System.Directory(copyFile)

main :: IO ()
main = do
  copyFile "/pfs/in/file" "/pfs/out/file"
